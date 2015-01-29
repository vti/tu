package Tu::Middleware::User;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Tu::Scope;
use Tu::Auth::Session;

use Plack::Util::Accessor qw(auth user_loader);

sub prepare_app {
    my $self = shift;

    if (!$self->{auth}) {
        croak 'user_loader required' unless $self->{user_loader};

        $self->{auth} =
          Tu::Auth::Session->new(user_loader => $self->{user_loader});
    }

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $user = $self->_user($env);

    my $res = $self->app->($env);

    return $self->response_cb(
        $res,
        sub {
            my $res = shift;

            $self->{auth}->finalize($env) if $user;
        }
    );
}

sub _user {
    my $self = shift;
    my ($env) = @_;

    my $scope = Tu::Scope->new($env);

    my $auth = $self->{auth};
    my $user = $auth->load($env);

    if ($user && $user->can('to_hash')) {
        $scope->displayer->vars->{user} = $user->to_hash;
    }

    $scope->set(auth      => $auth);
    $scope->set(auth_role => $user ? $user->role : 'anonymous');
    $scope->set(user      => $user);

    return $user;
}

1;
