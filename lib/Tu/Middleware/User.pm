package Tu::Middleware::User;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Tu::Loader;
use Tu::Scope;

use Plack::Util::Accessor qw(user_session_class);

sub call {
    my $self = shift;
    my ($env) = @_;

    my $user = $self->_user($env);

    my $res = $self->app->($env);

    return $self->response_cb(
        $res,
        sub {
            my $res = shift;

            $user->finalize if $user && $user->can('finalize');
        }
    );
}

sub _user {
    my $self = shift;
    my ($env) = @_;

    my $scope = Tu::Scope->new($env);

    Tu::Loader->new->load_class($self->user_session_class);

    my $user_session = $self->user_session_class->new(env => $env);

    my $user = $user_session->load;

    if ($user) {
        $scope->set(user      => $user);
        $scope->set(user_role => $user->role);
    }
    else {
        $scope->set(user      => undef);
        $scope->set(user_role => 'anonymous');
    }

    return $user;
}

1;
