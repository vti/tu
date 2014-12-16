package TestAppSimple::Action::Index;

use strict;
use warnings;

use parent 'Tu::Action';

sub run {
    my $self = shift;

    $self->set_var(foo => 'bar');

    return;
}

1;
