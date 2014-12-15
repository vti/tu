package Tu::Helper;

use strict;
use warnings;

use Scalar::Util qw(weaken);
use Tu::Scope;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env}      = $params{env};
    $self->{services} = $params{services};

    weaken $self->{env};

    return $self;
}

sub scope {
    my $self = shift;

    return Tu::Scope->new($self->{env});
}

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

sub params {
    my $self = shift;
    my ($key) = @_;

    return $self->scope->displayer->vars->{params} || {};
}

sub param {
    my $self = shift;
    my ($key) = @_;

    my $params = $self->params;
    return $params->{$key}->[0] if ref $params->{$key} eq 'ARRAY';
    return $params->{$key};
}

sub param_multi {
    my $self = shift;
    my ($key) = @_;

    my $params = $self->params;
    return [] unless exists $params->{$key};
    return $params->{$key} if ref $params->{$key} eq 'ARRAY';
    return [$params->{$key}];
}

1;
