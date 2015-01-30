package Tu::ServiceContainer::Routes;

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

    $services->register(routes => 'Tu::Routes', new => 1);

    $services->register(
        dispatcher => 'Tu::Dispatcher::Routes',
        new        => [qw/routes/]
    );

    return $self;
}

1;
