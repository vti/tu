package Tu::Plugin::DefaultServices;

use strict;
use warnings;

use parent 'Tu::Plugin';

sub startup {
    my $self = shift;

    $self->_register_services;

    $self->_add_middleware;

    return $self;
}

sub _register_services {
    my $self = shift;

    my $services = $self->services;

    $services->register(
        config  => 'Tu::Config',
        default => 1,
        new     => sub {
            my ($class, $services) = @_;
            my $home = $services->service('home');

            $class->new(mode => 1)->load($home->catfile('config/config.yml'));
        }
    );

    $services->register(
        routes  => 'Tu::Routes::FromConfig',
        default => 1,
        new     => sub {
            my ($class, $services) = @_;
            my $home = $services->service('home');

            $class->new->load($home->catfile('config/routes.yml'));
        }
    );

    $services->register(
        dispatcher => 'Tu::Dispatcher::Routes',
        default    => 1,
        new        => [qw/routes/]
    );

    $services->register(
        action_factory => 'Tu::ActionFactory',
        default        => 1,
        new            => sub {
            my ($class, $services) = @_;
            $class->new(
                namespaces => $services->service('app_class') . '::Action::');
        }
    );

    $services->register(layout => 'layout.apl', default => 1);
    $services->register(
        renderer => 'Tu::Renderer::APL',
        default  => 1,
        new      => [qw/home/]
    );

    $services->register(
        displayer => 'Tu::Displayer',
        default   => 1,
        new       => [qw/renderer layout/]
    );
}

sub _add_middleware {
    my $self = shift;

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
}

1;
