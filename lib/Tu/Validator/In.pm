package Tu::Validator::In;

use strict;
use warnings;

use base 'Tu::Validator::Base';

use List::Util qw(first);

sub is_valid {
    my $self = shift;
    my ($value, $in) = @_;

    return !!first { $value eq $_ } @$in;
}

1;
