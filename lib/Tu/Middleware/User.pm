package Tu::Middleware::User;

use strict;
use warnings;

use base 'Tu::Middleware';

use Carp qw(croak);
use Scalar::Util qw(blessed);

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{user_loader} = $params{user_loader};
    croak 'user_loader required' unless $self->{user_loader};

    if (blessed $params{user_loader}) {
        for (qw/load_from_session role to_hash/) {
            croak "user_loader must support $_()"
              unless $params{user_loader}->can($_);
        }
    }

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_user($env);

    return $self->app->($env);
}

sub _user {
    my $self = shift;
    my ($env) = @_;

    my $session = $env->{'psgix.session'};

    my $user;
    if ($session) {
        my $loader = $self->{user_loader};

        $user =
          blessed $loader
          ? $loader->load_from_session($session)
          : $loader->($session);

        $env->{'tu.displayer.vars'}->{user} = $user->to_hash if $user;
    }

    $user ||= Tu::Anonymous->new;

    $env->{'tu.user'} = $user;
}

package Tu::Anonymous;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub role { 'anonymous' }

1;
