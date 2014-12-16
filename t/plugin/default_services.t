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
    $services->register(app_class => 'MyApp');
    $services->register(home => Tu::Home->new(path => 'foo/bar'));

    my $plugin = _build_plugin(
        services => $services,
        builder  => $builder,
        config   => {},
        routes   => _mock_routes()
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
    $services->register(app_class => 'MyApp');
    $services->register(home => Tu::Home->new(path => 'foo/bar'));

    my $plugin = _build_plugin(
        services => $services,
        builder  => $builder,
        config   => {},
        routes   => _mock_routes()
    );

    $plugin->startup;

    ok $services->service('config');
    ok $services->service('routes');
    ok $services->service('dispatcher');
    ok $services->service('action_factory');
    ok $services->service('displayer');
};

done_testing;

sub _mock_renderer { Test::MonkeyMock->new }
sub _mock_routes   { Test::MonkeyMock->new }

sub _build_builder  { Tu::Builder->new }
sub _build_services { Tu::ServiceContainer->new }

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _build_services();

    Tu::Plugin::DefaultServices->new(%params);
}
