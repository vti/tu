package Tu::Middleware::RequestDispatcher;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Carp qw(croak);
use Encode ();
use Tu::Scope;
use Tu::X::HTTP;

use Plack::Util::Accessor qw(encoding dispatcher);

sub prepare_app {
    my $self = shift;

    $self->{encoding} ||= 'UTF-8';

    $self->{dispatcher} ||= $self->service('dispatcher')
      || croak 'dispatcher required';

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    $self->_dispatch($env);

    return $self->app->($env);
}

sub _dispatch {
    my $self = shift;
    my ($env) = @_;

    my $path = $env->{PATH_INFO} || '';
    my $method = $env->{REQUEST_METHOD};

    if ($self->encoding && $self->encoding ne 'raw') {
        $path = Encode::decode($self->encoding, $path);
    }

    my $dispatcher = $self->dispatcher;

    my $dispatched_request = $dispatcher->dispatch($path, method => lc $method);
    Tu::X::HTTP->throw('Not found', code => 404)
      unless $dispatched_request;

    Tu::Scope->new($env)->set(dispatched_request => $dispatched_request);

    return $self;
}

1;
