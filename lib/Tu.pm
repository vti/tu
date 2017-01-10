package Tu;

use strict;
use warnings;
use 5.012;

our $VERSION = '0.01';

use Tu::Home;
use Tu::X::HTTP;
use Tu::ServiceContainer;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{builder}  = $params{builder};
    $self->{services} = $params{services};

    my $app_class = ref $self;

    my $home = $params{home} || Tu::Home->new(app_class => $app_class);
    $home = Tu::Home->new(path => $home) unless ref $home;

    $self->{services} ||= Tu::ServiceContainer->new;
    $self->{services}->register(app_class => $app_class);
    $self->{services}->register(home      => $home);

    $self->startup;

    return $self;
}

sub services { $_[0]->{services} }

sub service {
    my $self = shift;
    my ($name) = @_;

    $self->{services}->service($name);
}

sub startup { $_[0] }

sub default_app {
    sub { Tu::X::HTTP->throw('Not Found', code => 404) }
}

sub to_app {
    my $self = shift;

    $self->{psgi_app} ||= $self->default_app;

    return $self->{psgi_app};
}

1;
__END__

=head1 NAME

Tu - tu

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 DEVELOPMENT

=head2 Repository

    http://github.com/vti/tu

=head1 AUTHOR

Viacheslav Tykhanovskyi, C<vti@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2014-2017, Viacheslav Tykhanovskyi

This program is free software, you can redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=cut
