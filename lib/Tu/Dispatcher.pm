package Tu::Dispatcher;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub dispatch {
    my $self = shift;
    my ($path, %args) = @_;

    ...;
}

1;
