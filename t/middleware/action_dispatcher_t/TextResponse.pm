package TextResponse;

use strict;
use warnings;

use base 'Tu::Action';

sub run {
    my $self = shift;

    return 'Text response!';
}

1;
