package Tu::Middleware::Session::Cookie;

use strict;
use warnings;

use parent 'Plack::Middleware::Session::Cookie';

sub new {
    my $class = shift;
    my (%params) = @_;

    my $services = delete $params{services};

    my $config = $services->service('config') || {};
    $config = $config->{session} || {};

    return $class->SUPER::new(%$config, %params);
}

sub call {
    my $self = shift;
    my $env  = shift;

    my ($id, $session) = $self->get_session($env);
    if ($id && $session) {
        $env->{'psgix.session'} = $session;
    }
    else {
        $id = $self->generate_id($env);
        $env->{'psgix.session'} = {};
    }

    $env->{'psgix.session.options'} = {id => $id};

    my $res;
    eval { $res = $self->app->($env) } or do {
        my $e = $@;

        $self->_finalize($res, $env) if $res;

        die $@;
    };

    return $self->_finalize;
}

sub _finalize {
    my $self = shift;
    my ($res, $env) = @_;

    return $self->response_cb($res, sub { $self->finalize($env, $_[0]) });
}

1;
