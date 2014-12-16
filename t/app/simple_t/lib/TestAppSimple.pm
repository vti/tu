package TestAppSimple;

use strict;
use warnings;

use base 'Tu';

sub startup {
    my $self = shift;

    $self->register_plugin('DefaultServices');
}

1;
