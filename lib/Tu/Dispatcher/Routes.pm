package Tu::Dispatcher::Routes;

use strict;
use warnings;

use parent 'Tu::Dispatcher';

use Carp qw(croak);
use Tu::DispatchedRequest::Routes;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{routes} = $params{routes};

    return $self;
}

sub dispatch {
    my $self = shift;
    my ($path, %args) = @_;

    my $routes = $self->{routes};

    my $m = $routes->match($path, %args);
    return unless $m;

    my $action = $m->params->{action} || $m->name;
    croak q{Action is unknown. Nor 'action' neither ->name was declared}
      unless $action;

    return $self->_build_dispatched_request(
        action   => $action,
        routes   => $self->{routes},
        captures => $m->params,
        params   => $m->arguments
    );
}

sub _build_dispatched_request {
    my $self = shift;

    return Tu::DispatchedRequest::Routes->new(@_);
}

1;
