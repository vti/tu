package Tu::Plugins;

use strict;
use warnings;

use Tu::Loader;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{namespaces} = $params{namespaces};
    $self->{loader}     = $params{loader};

    $self->{services} = $params{services};
    $self->{builder}  = $params{builder};

    $self->{plugins} = [];
    $self->{namespaces} ||= [];

    $self->{loader} ||=
      Tu::Loader->new(namespaces => [@{$self->{namespaces}}, qw/Tu::Plugin::/]);

    return $self;
}

sub register {
    my $self = shift;
    my ($plugin, @args) = @_;

    $plugin = $self->{loader}->load_class($plugin);

    my $instance = $plugin->new(
        services => $self->{services},
        builder  => $self->{builder},
        @args
    );

    $instance->startup;

    push @{$self->{plugins}}, $instance;

    return $self;
}

1;
