use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::ServiceContainer;
use Tu::Plugin::CommonServices;

subtest 'registers services' => sub {
    my $plugin = _build_plugin();

    $plugin->startup;

    ok $plugin->services->is_registered('config');
    ok $plugin->services->is_registered('routes');
    ok $plugin->services->is_registered('dispatcher');
    ok $plugin->services->is_registered('action_factory');
    ok $plugin->services->is_registered('displayer');
};

done_testing;

sub _build_services { Tu::ServiceContainer->new }

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _build_services();

    Tu::Plugin::CommonServices->new(%params);
}
