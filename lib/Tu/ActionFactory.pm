package Tu::ActionFactory;

use strict;
use warnings;

use parent 'Tu::Factory';

sub new {
    my $self = shift->SUPER::new(@_);

    $self->{try} = 1;

    return $self;
}

1;
