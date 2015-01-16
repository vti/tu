package Tu::ActionResponseResolver;

use strict;
use warnings;

use Carp qw(croak);

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub resolve {
    my $self = shift;
    my ($res, %options) = @_;

    return unless defined $res;

    return $res if ref $res eq 'ARRAY' || ref $res eq 'CODE';

    return $res->finalize if $res->isa('Tu::Response');

    croak 'unexpected return from action';
}

1;
