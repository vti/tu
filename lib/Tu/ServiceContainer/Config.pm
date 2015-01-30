package Tu::ServiceContainer::Config;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub register {
    my $self = shift;
    my ($services, %params) = @_;

    $self->{config_file} = $params{config_file} || 'config/config.yml';

    my $config_file = $self->{config_file};

    $services->register(
        config => 'Tu::Config',
        new    => sub {
            my ($class, $services) = @_;

            my $home = $services->service('home');
            $class->new(mode => 1)->load($home->catfile($config_file));
        }
    );

    return $self;
}

1;
