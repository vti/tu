package Tu::Middleware::Defaults;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Tu::Scope;
use Tu::HelperFactory::Persistent;

sub call {
    my $self = shift;
    my ($env) = @_;

    my $scope = Tu::Scope->new($env);

    my $vars = $scope->set('displayer.vars' => {});

    $vars->{mode} = $ENV{PLACK_ENV} || 'production';

    $vars->{helpers} =
      Tu::HelperFactory::Persistent->new(
        services   => $self->{services},
        namespaces => $self->{services}->service('app_class') . '::Helper::',
        env        => $env
      );

    return $self->app->($env);
}

1;
