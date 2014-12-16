package Tu::Plugin::Mailer;

use strict;
use warnings;

use parent 'Tu::Plugin';

use Carp qw(croak);
use Tu::Mailer;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{services} = $params{services} || croak 'services required';
    $self->{config} = $params{config};
    $self->{service_name} ||= 'mailer';

    return $self;
}

sub startup {
    my $self = shift;

    my $config =
         $self->{config}
      || $self->{services}->service('config')->{$self->{service_name}}
      || {};

    croak 'mailer not configured' unless %$config;

    my $mailer = $self->_build_mailer(%$config);
    $self->{services}->register($self->{service_name} => $mailer);
}

sub _build_mailer {
    my $self = shift;

    Tu::Mailer->new(@_);
}

1;
