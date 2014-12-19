package Tu::Mixin;

use strict;
use warnings;

sub import {
    my $orig_package = shift;

    return unless @_;

    my $package = caller();
    no strict 'refs';
    foreach my $method (@_) {
        *{$package . '::' . $method} = *{$orig_package . '::' . $method};
    }
}

1;
