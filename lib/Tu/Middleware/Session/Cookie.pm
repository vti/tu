package Tu::Middleware::Session::Cookie;

use strict;
use warnings;

use parent 'Plack::Middleware::Session::Cookie';

use Plack::Util::Accessor qw(services);

sub new {
    my $class = shift;
    my $params = @_ == 1 ? $_[0] : {@_};

    my $services = delete $params->{services};

    my $config = $services->service('config') || {};
    $config = $config->{session} || {};

    return $class->SUPER::new(%$params, %$config);
}

sub service {
    my $self = shift;
    my ($name) = @_;

    return $self->{services}->service($name);
}

1;
