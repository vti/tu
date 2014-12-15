package Tu::ValidatorResult;

use strict;
use warnings;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{messages}           = $params{messages};
    $self->{params}           = $params{params};
    $self->{errors}           = $params{errors} || {};
    $self->{validated_params} = $params{validated_params} || {};

    return $self;
}

sub add_error {
    my $self = shift;
    my ($name, $error) = @_;

    $self->{errors}->{$name} = $error;
}

sub errors {
    my $self = shift;

    my $errors = {};

    foreach my $name (keys %{$self->{errors}}) {
        my $error = $self->{errors}->{$name};
        $errors->{$name} = $self->_map_error($name, $error);
    }

    return $errors;
}

sub is_success {
    my $self = shift;

    return !%{$self->{errors}};
}

sub all_params       { $_[0]->{params} }
sub validated_params { $_[0]->{validated_params} }

sub _map_error {
    my $self = shift;
    my ($name, $error) = @_;

    for ("$name.$error", $error) {
        if (my $message = $self->{messages}->{$_}) {
            $error = $message;
            last;
        }
    }

    return $error;
}

1;
