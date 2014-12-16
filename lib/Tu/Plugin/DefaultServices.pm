package Tu::Plugin::DefaultServices;

use strict;
use warnings;

use parent 'Tu::Plugin';

use Tu::Config;
use Tu::Routes::FromConfig;
use Tu::Dispatcher::Routes;
use Tu::Displayer;
use Tu::ActionFactory;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{layout} = $params{layout} || 'layout.apl';
    $self->{renderer} = $params{renderer} || do {
        require Tu::Renderer::APL;
        Tu::Renderer::APL->new(home => $self->home);
    };
    $self->{config} = $params{config};
    $self->{routes} = $params{routes};

    return $self;
}

sub startup {
    my $self = shift;

    my $services  = $self->services;
    my $home      = $services->service('home');
    my $app_class = $services->service('app_class');

    $services->register(
        config => $self->{config}
          || do {
            Tu::Config->new(mode => 1)
              ->load($home->catfile('config/config.yml'));
          }
    );

    my $routes = $self->{routes}
      || Tu::Routes::FromConfig->new->load($home->catfile('config/routes.yml'));
    $services->register(routes => $routes);

    $services->register(
        dispatcher => Tu::Dispatcher::Routes->new(routes => $routes));

    $services->register(
        action_factory => Tu::ActionFactory->new(
            namespaces => $app_class . '::Action::'
        )
    );

    my $displayer = Tu::Displayer->new(
        renderer => $self->{renderer},
        layout   => $self->{layout}
    );
    $services->register(displayer => $displayer);

    $self->add_middleware(
        'ErrorDocument',
        403        => '/forbidden',
        404        => '/not_found',
        subrequest => 1
    );

    $self->add_middleware('HTTPExceptions');

    $self->add_middleware('Defaults');

    $self->add_middleware('Static');

    $self->add_middleware('RequestDispatcher');
    $self->add_middleware('ActionDispatcher');
    $self->add_middleware('ViewDisplayer');

    return $self;
}

1;
