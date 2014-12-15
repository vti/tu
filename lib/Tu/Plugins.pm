package Tu::Plugins;

use strict;
use warnings;

use Tu::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{plugins}    = $params{plugins};
    $self->{namespaces} = $params{namespaces};
    $self->{loader}     = $params{loader};

    $self->{app_class} = $params{app_class};
    $self->{services}  = $params{services};
    $self->{builder}   = $params{builder};
    $self->{home}      = $params{home};

    $self->{plugins} = [];
    $self->{namespaces} ||= [];

    $self->{loader} ||=
      Tu::Loader->new(
        namespaces => [@{$self->{namespaces}}, qw/Tu::Plugin::/]);

    return $self;
}

sub register {
    my $self = shift;
    my ($plugin, @args) = @_;

    $plugin = $self->{loader}->load_class($plugin);

    my $instance = $plugin->new(
        app_class => $self->{app_class},
        home      => $self->{home},
        services  => $self->{services},
        builder   => $self->{builder},
        @args
    );

    $instance->startup;

    push @{$self->{plugins}}, $instance;

    return $self;
}

1;
