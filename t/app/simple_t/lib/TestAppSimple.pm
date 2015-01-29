package TestAppSimple;

use strict;
use warnings;

use parent 'Tu';

sub startup {
    my $self = shift;

    $self->services->register_group('Tu::ServiceContainer::Common');

    $self->service('routes')->add_route('/', name => 'index');
}

1;
