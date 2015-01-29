package Tu::ServiceContainer::Mailer;

use strict;
use warnings;

use Carp qw(croak);
use Tu::Mailer;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub register {
    my $self = shift;
    my ($services, %params) = @_;

    my $config =
         $params{config}
      || $services->service('config')->{mailer}
      || {};

    croak 'mailer not configured' unless %$config;

    my $mailer = $self->_build_mailer(%$config);
    $services->register(mailer => $mailer);

    return $self;
}

sub _build_mailer {
    my $self = shift;

    Tu::Mailer->new(@_);
}

1;
