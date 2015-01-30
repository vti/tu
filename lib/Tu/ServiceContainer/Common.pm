package Tu::ServiceContainer::Common;

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

    $services->register_group('+Tu::ServiceContainer::Config',    %params);
    $services->register_group('+Tu::ServiceContainer::Routes',    %params);
    $services->register_group('+Tu::ServiceContainer::Actions',   %params);
    $services->register_group('+Tu::ServiceContainer::Displayer', %params);

    return $self;
}

1;
