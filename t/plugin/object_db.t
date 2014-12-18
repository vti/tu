use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::Plugin::ObjectDB;

subtest 'inits database' => sub {
    my $plugin = _build_plugin(services_args =>
          {app_class => 'TestApp', config => {database => {foo => 'bar'}}});

    $plugin->startup;

    is_deeply TestApp::DB->args, [foo => 'bar'];
};

subtest 'inits database from specified config key' => sub {
    my $plugin = _build_plugin(
        config_key => 'db',
        services_args =>
          {app_class => 'TestApp', config => {db => {foo => 'bar'}}}
    );

    $plugin->startup;

    is_deeply TestApp::DB->args, [foo => 'bar'];
};

subtest 'inits database from specified class' => sub {
    my $plugin = _build_plugin(
        db_class      => 'TestApp::Custom',
        services_args => {config => {database => {foo => 'bar'}}}
    );

    $plugin->startup;

    is_deeply TestApp::Custom->custom_args, [foo => 'bar'];
};

done_testing;

sub _mock_services {
    my (%params) = @_;

    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { $params{$_[1]} });
}

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _mock_services(%{$params{services_args} || {}});

    Tu::Plugin::ObjectDB->new(%params);
}

package TestApp::DB;
my $args;

sub init_db {
    shift;
    $args = [@_];
}
sub args { $args }

package TestApp::Custom;
my $custom_args;

sub init_db {
    shift;
    $custom_args = [@_];
}
sub custom_args { $custom_args }
