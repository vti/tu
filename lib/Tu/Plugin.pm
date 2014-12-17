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

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

sub home { $_[0]->service('home') }

sub builder { $_[0]->{builder} }

sub add_middleware {
    my $self = shift;
    my ($name, %params) = @_;

    $self->builder->add_middleware($name, services => $self->services, %params);
}

sub insert_before_middleware {
    my $self = shift;
    my ($before, $name, %params) = @_;

    $self->builder->insert_before_middleware(
        $before, $name,
        services => $self->services,
        %params
    );
}

sub startup { }

1;
