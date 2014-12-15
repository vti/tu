package Tu::Validator::Base;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{fields}  = $params{fields};
    $self->{args}    = $params{args};

    return $self;
}

sub name {
    my $self = shift;

    my $name = ref $self;
    $name =~ s/^.*?::Validator:://;

    return uc $name;
}

sub validate {
    my $self = shift;
    my ($params) = @_;

    my $is_group = @{$self->{fields}} > 1;

    my $value;

    if ($is_group) {
        $value = [];
        $value = [map { $params->{$_} } @{$self->{fields}}];

        return $self->is_valid($value, @{$self->{args}});
    }

    $value = $params->{$self->{fields}->[0]};

    $value = [$value] unless ref $value eq 'ARRAY';
    foreach (@$value) {
        return 0 unless $self->is_valid($_, @{$self->{args}});
    }

    return 1;
}

sub is_valid { ... }

1;
