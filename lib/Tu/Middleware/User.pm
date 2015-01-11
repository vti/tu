package Tu::Middleware::User;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Tu::Scope;
use Tu::Auth::Session;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{auth} = $params{auth};

    if (!$self->{auth}) {
        croak 'user_loader required' unless $params{user_loader};

        $self->{auth} =
          Tu::Auth::Session->new(user_loader => $params{user_loader});
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

    my $scope = Tu::Scope->new($env);

    my $auth = $self->{auth};
    my $user = $auth->load($env);

    if ($user && $user->can('to_hash')) {
        $scope->displayer->vars->{user} = $user->to_hash;
    }

    $scope->set(auth      => $auth);
    $scope->set(auth_role => $user ? $user->role : 'anonymous');
    $scope->set(user      => $user);
}

1;
