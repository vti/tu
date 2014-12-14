package Tu::Validator::Callback;

use strict;
use warnings;

use base 'Tu::Validator::Base';

sub is_valid {
    my $self = shift;
    my ($value, $cb) = @_;

    return $cb->($self, $value);
}

1;
