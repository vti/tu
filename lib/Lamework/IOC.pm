package Lamework::IOC;

use strict;
use warnings;

use base 'Lamework::Base';

require Carp;

use Class::Load  ();
use Scalar::Util ();

sub register {
    my $self = shift;
    my ($key, $service, %attrs) = @_;

    Carp::croak('Service name is required')  unless $key;
    Carp::croak('Service class is required') unless $service;

    $self->{services}->{$key} = {attrs => {%attrs}};

    if (Scalar::Util::blessed($service)) {
        $self->{services}->{$key}->{instance} = $service;
    }
    else {
        $self->{services}->{$key}->{class} = $service;
    }

    return $self;
}

sub register_constant {
    my $self = shift;
    my ($key, $constant) = @_;

    $self->{services}->{$key} = {constant => $constant};

    return $self;
}

sub create {
    my $self = shift;
    my ($key) = @_;

    my $service = $self->_get($key);

    return $self->_build_service($service);
}

sub get {
    my $self = shift;
    my ($key) = @_;

    my $service = $self->_get($key);

    return $service->{instance} if exists $service->{instance};

    return $service->{instance} = $self->_build_service($service);
}

sub get_all {
    my $self = shift;

    my @services;
    foreach my $service (keys %{$self->{services}}) {
        push @services, $self->get($service);
    }

    return @services;
}

sub _get {
    my $self = shift;
    my ($key) = @_;

    die "Service '$key' does not exist"
      unless exists $self->{services}->{$key};

    return $self->{services}->{$key};
}

sub _build_service {
    my $self = shift;
    my ($service) = @_;

    return $service->{constant} if exists $service->{constant};

    Class::Load::load_class($service->{class});

    my %args;
    my %methods;
    if (my $deps = $service->{attrs}->{deps}) {
        $deps = [$deps] unless ref $deps eq 'ARRAY';

        my $aliases = $service->{attrs}->{aliases};

        foreach my $dep (@$deps) {
            my $key = $dep;

            if ($aliases && $aliases->{$key}) {
                $key = $aliases->{$key};
            }

            $args{$key} = $self->get($dep);

            if (my $setters = $service->{attrs}->{setters}) {
                next unless my $setter = $setters->{$dep};

                $methods{$setter} = delete $args{$key};
            }
        }
    }

    my $instance = $service->{class}->new(%args);

    foreach my $method (keys %methods) {
        $instance->$method($methods{$method});
    }

    return $instance;
}

1;
