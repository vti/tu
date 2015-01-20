package Tu::DispatchedRequest;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{action}   = $params{action};
    $self->{captures} = $params{captures} || {};
    $self->{params}   = $params{params} || {};

    return $self;
}

sub build_path { ... }

sub action {
    my $self = shift;

    return $self->{action};
}

sub captures {
    my $self = shift;

    return $self->{captures};
}

sub params {
    my $self = shift;

    return $self->{params};
}

1;
