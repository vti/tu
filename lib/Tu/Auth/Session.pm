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

    my $session = Plack::Session->new($env);
    return unless my $id = $session->get('user_id');

    return $self->{user_loader}->load_by_auth_id($id);
}

sub login {
    my $self = shift;
    my ($env, $id) = @_;

    my $session = Plack::Session->new($env);
    $session->set(user_id => $id);
}

sub logout {
    my $self = shift;
    my ($env) = @_;

    my $session = Plack::Session->new($env);
    $session->expire;
}

1;
