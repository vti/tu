package Tu::Middleware;

use strict;
use warnings;

use parent 'Plack::Middleware';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{services} = $params{services};

    return $self;
}

sub services { $_[0]->{services} }

1;
