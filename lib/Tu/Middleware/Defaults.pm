package Tu::Middleware::Defaults;

use strict;
use warnings;

use parent 'Tu::Middleware';

use Tu::Scope;
use Tu::HelperFactory::Persistent;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{app_class} = $params{app_class};

    return $self;
}

sub call {
    my $self = shift;
    my ($env) = @_;

    my $scope = Tu::Scope->new($env);

    my $vars = $scope->set('displayer.vars' => {});

    $vars->{mode} = $ENV{PLACK_ENV} || 'production';

    $vars->{helpers} =
      Tu::HelperFactory::Persistent->new(
        namespaces => $self->{app_class} . '::Helper::',
        services   => $self->{services},
        env        => $env
      );

    return $self->app->($env);
}

1;
