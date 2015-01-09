package Tu::Auth::Session;

use strict;
use warnings;

use Carp qw(croak);
use Plack::Session;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{user_loader} = $params{user_loader};

    croak 'user_loader required' unless $self->{user_loader};

    return $self;
}

sub session {
    my $self = shift;
    my ($env) = @_;

    my $session = $self->_build_session($env);

    return $session->dump || {};
}

sub load {
    my $self = shift;
    my ($env) = @_;

    my $session = $self->_build_session($env);

    my $options = $session->dump || {};

    my $user = $self->{user_loader}->load_auth($options);

    if ($options && ref $options eq 'HASH') {
        $session->set($_ => $options->{$_}) for keys %$options;
    }

    return $user;
}

sub login {
    my $self = shift;
    my ($env, $options) = @_;

    my $session = $self->_build_session($env);

    if ($options && ref $options eq 'HASH') {
        $session->set($_ => $options->{$_}) for keys %$options;
    }

    return $self;
}

sub logout {
    my $self = shift;
    my ($env) = @_;

    my $session = $self->_build_session($env);
    $session->expire;

    return $self;
}

sub _build_session {
    my $self = shift;
    my ($env) = @_;

    $env->{'psgix.session'}         ||= {};
    $env->{'psgix.session.options'} ||= {};

    return Plack::Session->new($env);
}

1;
