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

sub load {
    my $self = shift;
    my ($env) = @_;

    my $session = $self->_build_session($env);
    return unless my $id = $session->get('user_id');

    return $self->{user_loader}->load_by_auth_id($id, $session->dump);
}

sub login {
    my $self = shift;
    my ($env, $id, $options) = @_;

    my $session = $self->_build_session($env);
    $session->set(user_id => $id);

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
