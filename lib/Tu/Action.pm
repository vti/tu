package Tu::Action;

use strict;
use warnings;

use Carp qw(croak);
use Tu::X::HTTP;
use Tu::Scope;
use Tu::Request;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{env} = $params{env} || croak '$env required';
    $self->{services} = $params{services};

    return $self;
}

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

sub env {
    my $self = shift;

    return $self->{env};
}

sub scope { Tu::Scope->new($_[0]->{env}) }

sub req {
    my $self = shift;

    $self->{req} ||= Tu::Request->new($self->env);

    return $self->{req};
}

sub new_response {
    my $self = shift;

    return $self->req->new_response(@_);
}

sub url_for {
    my $self = shift;
    my ($url_or_name, %params) = @_;

    my $url;

    if ($_[0] =~ m{^/}) {
        my $path = $url_or_name;
        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }
    elsif ($_[0] =~ m{^https?://}) {
        $url = $_[0];
    }
    else {
        my $dispatched_request = $self->scope->dispatched_request;

        my $path = $dispatched_request->build_path($url_or_name, %params);

        $path =~ s{^/}{};

        $url = $self->req->base;
        $url->path($url->path . $path);
    }

    return $url;
}

sub captures { $_[0]->scope->dispatched_request->captures }

sub set_var {
    my $self = shift;

    my $vars_scope = $self->scope->displayer->vars;
    for (my $i = 0; $i < @_; $i += 2) {
        my $key   = $_[$i];
        my $value = $_[$i + 1];

        $vars_scope->{$key} = $value;
    }

    return $self;
}

sub throw_forbidden {
    my $self = shift;
    my ($message) = @_;

    $self->throw_error($message, 403);
}

sub throw_not_found {
    my $self = shift;
    my ($message) = @_;

    $self->throw_error($message, 404);
}

sub throw_error {
    my $self = shift;
    my ($message, $code) = @_;

    Tu::X::HTTP->throw($message, code => $code || 500);
}

sub redirect {
    my $self = shift;
    my ($path, @args) = @_;

    my $status = 302;
    if (@args % 2 != 0) {
        $status = pop @args;
    }

    my $url = $self->url_for($path, @args);

    my $res = $self->new_response($status);
    $res->header(Location => $url);

    return $res;
}

sub render {
    my $self = shift;
    my ($template, %args) = @_;

    my $displayer_scope = $self->scope->displayer;

    $args{vars} = {%{$displayer_scope->vars}, %{$args{vars} || {}}};

    if ($displayer_scope->exists('layout')
        && !exists $args{layout})
    {
        $args{layout} = $displayer_scope->layout;
    }

    return $self->service('displayer')->render($template, %args);
}

1;
