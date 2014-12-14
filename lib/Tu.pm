package Tu;

use strict;
use warnings;

our $VERSION = '0.1';

use Tu::Builder;
use Tu::Home;
use Tu::Exception::HTTP;
use Tu::Plugins;
use Tu::ServiceContainer;

use overload q(&{}) => sub { shift->to_app }, fallback => 1;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{home}     = $params{home};
    $self->{builder}  = $params{builder};
    $self->{services} = $params{services};
    $self->{plugins}  = $params{plugins};

    my $app_class = ref $self;

    $self->{home} ||= Tu::Home->new(app_class => $app_class);
    if (!ref $self->{home}) {
        $self->{home} = Tu::Home->new(path => $self->{home});
    }

    $self->{builder} ||=
      Tu::Builder->new(namespaces => [$app_class . '::Middleware::']);
    $self->{services} ||= Tu::ServiceContainer->new;

    $self->{plugins} ||= Tu::Plugins->new(
        namespaces => [$app_class . '::Plugin::'],
        app_class  => $app_class,
        home       => $self->{home},
        builder    => $self->{builder},
        services   => $self->{services},
    );

    $self->startup;

    return $self;
}

sub home     { $_[0]->{home} }
sub services { $_[0]->{services} }
sub service  { shift->{services}->service(@_) }

sub startup { $_[0] }

sub add_middleware {
    my $self = shift;
    my ($name, @args) = @_;

    return $self->{builder}
      ->add_middleware($name, services => $self->{services}, @args);
}

sub insert_before_middleware {
    my $self = shift;
    my ($before, $name, @args) = @_;

    return $self->{builder}->insert_before_middleware(
        $before, $name,
        services => $self->{services},
        @args
    );
}

sub register_plugin {
    my $self = shift;

    return $self->{plugins}->register_plugin(@_);
}

sub default_app {
    sub { Tu::Exception::HTTP->throw('Not Found', code => 404) }
}

sub to_app {
    my $self = shift;

    $self->{psgi_app} ||= do {
        my $app = $self->{builder}->wrap($self->default_app);

        sub {
            my $env = shift;

            $env->{'turnaround.services'} = $self->{services};

            $self->{plugins}->run_plugins($env);

            $app->($env);
          }
    };

    return $self->{psgi_app};
}

1;
