package TestAppSimple;

use strict;
use warnings;

use base 'Tu';

sub startup {
    my $self = shift;

    $self->register_plugin('DefaultServices');

    $self->service('routes')->add_route('/', name => 'index');
}

1;
