package Tu::Observer::Base;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    $self->_init;

    return $self;
}

sub _init {
}

sub _register {
    my $self = shift;
    my ($event, $cb) = @_;

    $self->{events}->{$_} = $cb for split /,/, $event;

    return $self;
}

sub events { $_[0]->{events} }

1;
