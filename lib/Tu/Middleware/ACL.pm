package Tu::Middleware::ACL;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Scalar::Util qw(blessed);
use Tu::Scope;
use Tu::X::HTTP;

use Plack::Util::Accessor qw(acl);

sub prepare_app {
    my $self = shift;

    $self->{acl} ||= $self->service('acl') || croak 'acl required';

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_acl($env);
    return $res if $res;

    return $self->app->($env);
}

sub _acl {
    my $self = shift;
    my ($env) = @_;

    return $self->_deny($env) unless my $auth_role = $env->{'tu.auth_role'};

    my $action = $self->_find_action($env);

    my $acl = $self->{acl} || $self->service('acl');
    return $self->_deny($env) unless $acl->is_allowed($auth_role, $action);

    return;
}

sub _find_action {
    my $self = shift;
    my ($env) = @_;

    return Tu::Scope->new($env)->dispatched_request->action;
}

sub _deny {
    my $self = shift;
    my ($env) = @_;

    my $redirect_to = $self->{redirect_to};
    if (defined $redirect_to && $env->{PATH_INFO} ne $redirect_to) {
        return [302, ['Location' => $redirect_to], ['']];
    }

    Tu::X::HTTP->throw('Not Found', code => 404);
}

1;
