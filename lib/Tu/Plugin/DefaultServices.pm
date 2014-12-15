package Tu::Plugin::DefaultServices;

use strict;
use warnings;

use base 'Tu::Plugin';

use Tu::Request;
use Tu::Config;
use Tu::Routes::FromConfig;
use Tu::Dispatcher::Routes;
use Tu::Displayer;
use Tu::ActionFactory;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{layout} = $params{layout} // 'layout.apl';
    $self->{renderer} = $params{renderer} || do {
        require Tu::Renderer::APL;
        Tu::Renderer::APL->new(home => $self->{home});
    };
    $self->{config} = $params{config};
    $self->{routes} = $params{routes};

    return $self;
}

sub startup {
    my $self = shift;

    my $home     = $self->home;
    my $services = $self->services;

    $services->register(home => $home);

    $services->register(
        config => $self->{config}
          || do { Tu::Config->new(mode => 1)->load('config/config.yml') }
    );

    my $routes = $self->{routes}
      || Tu::Routes::FromConfig->new->load('config/routes.yml');
    $services->register(routes => $routes);

    $services->register(
        dispatcher => Tu::Dispatcher::Routes->new(routes => $routes));

    $services->register(
        action_factory => Tu::ActionFactory->new(
            namespaces => $self->{app_class} . '::Action::'
        )
    );

    my $displayer = Tu::Displayer->new(
        renderer => $self->{renderer},
        layout   => $self->{layout}
    );
    $services->register(displayer => $displayer);

    $self->builder->add_middleware(
        'ErrorDocument',
        403        => '/forbidden',
        404        => '/not_found',
        subrequest => 1
    );

    $self->builder->add_middleware('HTTPExceptions');

    $self->builder->add_middleware(
        'Defaults',
        app_class => $self->{app_class},
        services  => $services
    );

    my $public_dir = $home->catfile('public');

    my @dirs = grep { -d } glob "$public_dir/*";
    s/^$public_dir\/?// for @dirs;

    my $re = '^/(?:' . join('|', @dirs) . ')/';
    $self->builder->add_middleware(
        'Static',
        path => qr/$re/,
        root => $self->{home}->catfile('public')
    );

    $self->builder->add_middleware('RequestDispatcher', services => $services);
    $self->builder->add_middleware('ActionDispatcher',  services => $services);
    $self->builder->add_middleware('ViewDisplayer',     services => $services);

    return $self;
}

1;
