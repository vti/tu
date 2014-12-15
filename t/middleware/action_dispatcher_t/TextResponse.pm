package TextResponse;

use strict;
use warnings;

use parent 'Tu::Action';

sub run {
    my $self = shift;

    return 'Text response!';
}

1;
