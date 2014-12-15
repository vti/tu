package Tu::X::HTTP;

use strict;
use warnings;

use parent 'Tu::X::Base';

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{code} = $params{code};

    return $self;
}

sub code { $_[0]->{code} || 500 }

sub as_string { $_[0]->{message} }

1;
