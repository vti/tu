package Tu::Middleware;

use strict;
use warnings;

use parent 'Plack::Middleware';

use Plack::Util::Accessor qw(services);

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

1;
