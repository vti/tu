package Tu::Middleware::ActionDispatcher;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Tu::Scope;
use Tu::ActionResponseResolver;

use Plack::Util::Accessor qw(action_factory response_resolver);

sub prepare_app {
    my $self = shift;

    $self->{action_factory} ||= $self->service('action_factory')
      || croak 'action_factory required';

    $self->{response_resolver} ||= Tu::ActionResponseResolver->new;

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $res = $self->_action($env);
    return $res if $res;

    return $self->app->($env);
}

sub _action {
    my $self = shift;
    my ($env) = @_;

    my $dispatched_request = Tu::Scope->new($env)->dispatched_request;

    my $action = $dispatched_request->action;
    return unless defined $action;

    $action = $self->_build_action($action, $env);
    return unless defined $action;

    my @res = $action->run;

    return $self->response_resolver->resolve(@res);
}

sub _build_action {
    my $self = shift;
    my ($action, $env) = @_;

    return $self->action_factory->build(
        $action,
        env      => $env,
        services => $self->{services}
    );
}

1;
