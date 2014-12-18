package Tu::ServiceContainer;

use strict;
use warnings;

use Carp qw(croak);
use Tu::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{services} = {};
    $self->{loader}   = $params{loader};

    $self->{loader} ||= Tu::Loader->new;

    return $self;
}

sub is_registered {
    my $self = shift;
    my ($name) = @_;

    return !!exists $self->{services}->{$name};
}

sub register {
    my $self = shift;
    my ($name, $value, %params) = @_;

    if (exists $self->{services}->{$name}) {
        croak qq{service '$name' already registered};
    }

    $self->{services}->{$name} = {value => $value, %params};

    return $self;
}

sub overwrite {
    my $self = shift;
    my ($name, $value, %params) = @_;

    $self->{services}->{$name} = {value => $value, %params};

    return $self;
}

sub service {
    my $self = shift;
    my ($name) = @_;

    croak qq{unknown service '$name'} unless exists $self->{services}->{$name};

    my $service = $self->{services}->{$name};

    my $instance;

    if (ref $service->{value} eq 'CODE') {
        $instance = $service->{value}->($self);
    }
    elsif ($service->{new}) {
        if (!$service->{instance}) {
            my $service_class = $self->{loader}->load_class($service->{value});

            my %deps;
            if (ref $service->{new} eq 'ARRAY') {
                $deps{$_} = $self->service($_) for @{$service->{new}};
            }
            elsif (ref $service->{new} eq 'CODE') {
                $service->{instance} = $service->{new}->($service_class, $self);
            }

            $service->{instance} ||= $service_class->new(%deps);
        }

        $instance = $service->{instance};
    }
    else {
        $instance = $service->{value};
    }

    return $instance;
}

1;
