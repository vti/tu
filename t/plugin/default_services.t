use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::Home;
use Tu::Builder;
use Tu::ServiceContainer;
use Tu::Plugin::DefaultServices;

subtest 'adds middleware in correct order' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();

    my $plugin = _build_plugin(
        services => $services,
        builder  => $builder,
    );

    $plugin->startup;

    is_deeply $builder->list_middleware, [
        qw/
          ErrorDocument
          HTTPExceptions
          Defaults
          Static
          RequestDispatcher
          ActionDispatcher
          ViewDisplayer
          /
    ];
};

subtest 'registers services' => sub {
    my $builder  = _build_builder();
    my $services = _build_services();

    my $plugin = _build_plugin(
        services => $services,
        builder  => $builder,
    );

    $plugin->startup;

    ok $services->is_registered('config');
    ok $services->is_registered('routes');
    ok $services->is_registered('dispatcher');
    ok $services->is_registered('action_factory');
    ok $services->is_registered('displayer');
};

done_testing;

sub _build_builder  { Tu::Builder->new }
sub _build_services { Tu::ServiceContainer->new }

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _build_services();

    Tu::Plugin::DefaultServices->new(%params);
}
