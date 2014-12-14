package MyApp;

use strict;
use warnings;

use base 'Tu';

use Tu::Home;
use Tu::Routes;
use Tu::Renderer::Caml;

sub startup {
    my $self = shift;

    $self->{home} = Tu::Home->new(path => 't/functional_tests');

    $self->register_plugin(
        'DefaultServices',
        config   => {},
        routes   => $self->_build_routes,
        renderer => Tu::Renderer::Caml->new(home => $self->{home}),
        layout   => ''
    );

    return $self;
}

sub _build_routes {
    my $self = shift;

    my $routes = Tu::Routes->new;
    $routes->add_route('/:action');

    return $routes;
}

1;
