package Tu::Dispatcher;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub dispatch { ... }

1;
