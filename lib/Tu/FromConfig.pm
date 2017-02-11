package Tu::FromConfig;

use strict;
use warnings;

use Tu::Config;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{config} = $params{config};

    $self->{config} ||= Tu::Config->new;

    return $self;
}

sub load {
    my $self = shift;
    my ($path) = @_;

    my $config = $self->{config}->load($path);

    return $self->_from_config($config);
}

sub _from_config {
    my $self = shift;
    my ($config) = @_;

    return $config;
}

1;
