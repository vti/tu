package Tu::ACL;

use strict;
use warnings;

use Carp qw(croak);
use List::Util qw(first);
use Scalar::Util qw(blessed);

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub add_role {
    my $self = shift;
    my ($role, @parents) = @_;

    $self->{roles}->{$role} = {allow => [], deny => []};

    foreach my $parent (@parents) {
        push @{$self->{roles}->{$role}->{deny}},
          @{$self->{roles}->{$parent}->{deny}};
        push @{$self->{roles}->{$role}->{allow}},
          @{$self->{roles}->{$parent}->{allow}};
    }

    return $self;
}

sub allow {
    my $self = shift;
    my ($role, $action, %options) = @_;

    if ($role eq '*') {
        foreach my $role (keys %{$self->{roles}}) {
            $self->allow($role, $action, %options);
        }
    }
    else {
        croak 'Unknown role' unless $self->_role_exists($role);

        push @{$self->{roles}->{$role}->{allow}}, {action => $action, options => \%options};
    }

    return $self;
}

sub deny {
    my $self = shift;
    my ($role, $action, %options) = @_;

    if ($role eq '*') {
        foreach my $role (keys %{$self->{roles}}) {
            $self->deny($role, $action, %options);
        }
    }
    else {
        croak 'Unknown role' unless $self->_role_exists($role);

        push @{$self->{roles}->{$role}->{deny}}, {action => $action, options => \%options};
    }

    return $self;
}

sub is_allowed {
    my $self = shift;
    my ($role, $action, %params) = @_;

    return 0 unless $self->_role_exists($role);

    foreach my $denied_action (@{$self->{roles}->{$role}->{deny}}) {
        if ($self->_equals($action, $denied_action->{action})) {
            if ($self->_eval_options($denied_action, $role, $action, %params)) {
                return 0;
            }
        }
    }

    if (my $allow_action = first { $_->{action} eq $action || $_->{action} eq '*' }
        @{$self->{roles}->{$role}->{allow}})
    {
        return $self->_eval_options($allow_action, $role, $action, %params);

        return 1;
    }

    return 0;
}

sub _eval_options {
    my $self = shift;
    my ($action, @args) = @_;

    return 1
      unless $action
      && $action->{options}
      && (my $when = $action->{options}->{when});

    if (ref $when eq 'CODE') {
        return $when->(@args);
    }
    elsif (blessed $when) {
        return $when->check(@args);
    }

    return 0;
}

sub _role_exists {
    my $self = shift;
    my ($role) = @_;

    return exists $self->{roles}->{$role};
}

sub _equals {
    my $self = shift;
    my ($action, $denied_action) = @_;

    if (ref $denied_action eq 'Regexp') {
        return 1 if $action =~ $denied_action;
    }
    else {
        return 1 if $action eq $denied_action;
    }

    return 0;
}

1;
