package Tu::ActionFactory;

use strict;
use warnings;

use Tu::Factory;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{factory} = $params{factory} || Tu::Factory->new(try => 1, %params);

    return $self;
}

sub build {
    my $self = shift;
    my ($action, %args) = @_;

    return $self->{factory}->build($action, %args);
}

1;
