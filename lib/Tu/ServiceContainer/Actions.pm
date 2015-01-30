package Tu::ServiceContainer::Actions;

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
        action_factory => $params{action_factory} || 'Tu::ActionFactory',
        new => sub {
            my ($class, $services) = @_;
            $class->new(
                namespaces => $services->service('app_class') . '::Action::');
        }
    );

    return $self;
}

1;
