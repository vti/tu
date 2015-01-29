package Tu::ServiceContainer::Common;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub register {
    my $self = shift;
    my ($services, %params) = @_;

    $self->{config_file} = $params{config_file} || 'config/config.yml';

    my $config_file = $self->{config_file};

    $self->register(
        config => 'Tu::Config',
        new    => sub {
            my ($class, $services) = @_;

            my $home = $services->service('home');
            $class->new(mode => 1)->load($home->catfile($config_file));
        }
    );

    $self->register(routes => 'Tu::Routes', new => 1);

    $self->register(
        dispatcher => 'Tu::Dispatcher::Routes',
        new        => [qw/routes/]
    );

    $self->register(
        action_factory => $params{action_factory} || 'Tu::ActionFactory',
        new            => sub {
            my ($class, $services) = @_;
            $class->new(
                namespaces => $services->service('app_class') . '::Action::');
        }
    );

    $self->register(
        templates_path => sub {
            shift->service('config')->{templates_path} || 'templates';
        }
    );
    $self->register(
        renderer => 'Tu::Renderer::APL',
        new      => [qw/home templates_path/]
    );

    $self->register(layout => 'layout.apl');
    $self->register(
        displayer => 'Tu::Displayer',
        new       => [qw/renderer layout/]
    );

    return $self;
}

1;
