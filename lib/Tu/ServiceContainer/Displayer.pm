package Tu::ServiceContainer::Displayer;

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

    $services->register(
        templates_path => $params{templates_path} || sub {
            shift->service('config')->{templates_path} || 'templates';
        }
    );
    $services->register(
        renderer => $params{renderer} || 'Tu::Renderer::APL',
        new => [qw/home templates_path/]
    );

    $services->register(layout => $params{layout} || 'layout.apl');
    $services->register(
        displayer => 'Tu::Displayer',
        new       => [qw/renderer layout/]
    );

    return $self;
}

1;
