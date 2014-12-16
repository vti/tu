package Tu::Plugin;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{services} = $params{services};
    $self->{builder}  = $params{builder};

    return $self;
}

sub services { $_[0]->{services} }
sub service  { shift->{services}->service(@_) }
sub home     { $_[0]->service('home') }

sub builder { $_[0]->{builder} }

sub add_middleware {
    my $self = shift;
    my ($name, @args) = @_;

    $self->builder->add_middleware($name, services => $self->services, @args);
}

sub insert_before_middleware {
    my $self = shift;
    my ($before, $name, @args) = @_;

    $self->builder->insert_before_middleware(
        $before, $name,
        services => $self->services,
        @args
    );
}

sub startup { }

1;
