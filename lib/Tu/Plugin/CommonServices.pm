package Tu::Plugin::CommonServices;

use strict;
use warnings;

use parent 'Tu::Plugin';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{config_file} = $params{config_file} || 'config/config.yml';

    return $self;
}

sub startup {
    my $self = shift;

    my $services = $self->services;

    my $config_file = $self->{config_file};
    $services->register(
        config => 'Tu::Config',
        new    => sub {
            my ($class, $services) = @_;

            my $home = $services->service('home');
            $class->new(mode => 1)->load($home->catfile($config_file));
        }
    );

    $services->register(routes => 'Tu::Routes', new => 1);

    $services->register(
        dispatcher => 'Tu::Dispatcher::Routes',
        new        => [qw/routes/]
    );

    $services->register(
        action_factory => 'Tu::ActionFactory',
        new            => sub {
            my ($class, $services) = @_;
            $class->new(
                namespaces => $services->service('app_class') . '::Action::');
        }
    );

    $services->register(
        templates_path => sub {
            shift->service('config')->{templates_path} || 'templates';
        }
    );
    $services->register(
        renderer => 'Tu::Renderer::APL',
        new      => [qw/home templates_path/]
    );

    $services->register(layout => 'layout.apl');
    $services->register(
        displayer => 'Tu::Displayer',
        new       => [qw/renderer layout/]
    );
}

1;