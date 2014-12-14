package Plugin;

use strict;
use warnings;

use base 'Tu::Plugin';

sub run {
    my $self = shift;
    my ($env) = @_;

    $env->{foo} = 'bar';
}

1;
