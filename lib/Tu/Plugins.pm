package Tu::Plugins;

use strict;
use warnings;

use Carp qw(croak);
use List::Util qw(first);
use Tu::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{namespaces} = $params{namespaces};
    $self->{loader}     = $params{loader};

    $self->{services} = $params{services} || croak 'services required';
    $self->{builder}  = $params{builder}  || croak 'builder required';

    $self->{plugins} = {};
    $self->{namespaces} ||= [];

    $self->{loader} ||=
      Tu::Loader->new(namespaces => [@{$self->{namespaces}}, qw/Tu::Plugin::/]);

    return $self;
}

sub register {
    my $self = shift;
    my ($plugin, %params) = @_;

    croak "plugin '$plugin' already registered" if $self->{plugins}->{$plugin};

    $self->{plugins}->{$plugin}++;

    $plugin = $self->{loader}->load_class($plugin);

    my $instance = $plugin->new(
        services => $self->{services},
        builder  => $self->{builder},
        %params
    );

    $instance->startup;

    return $self;
}

1;
