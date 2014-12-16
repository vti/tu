use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Tu::ServiceContainer;
use Tu::Plugin::Mailer;

subtest 'throws when mailer not configured' => sub {
    my $services = _build_services();
    $services->register(config => {});

    my $plugin = _build_plugin(services => $services);

    like exception { $plugin->startup }, qr/mailer not configured/;
};

subtest 'registers service' => sub {
    my $services = _build_services();
    $services->register(config => {mailer => {foo => 'bar'}});

    my $plugin = _build_plugin(services => $services);
    $plugin = Test::MonkeyMock->new($plugin);
    $plugin->mock(_build_mailer => sub { _mock_mailer() });

    $plugin->startup;

    ok $services->service('mailer');
    is_deeply { $plugin->mocked_call_args('_build_mailer') }, {foo => 'bar'};
};

done_testing;

sub _mock_mailer { Test::MonkeyMock->new }

sub _build_services { Tu::ServiceContainer->new }

sub _build_plugin {
    my (%params) = @_;

    $params{services} ||= _build_services();

    Tu::Plugin::Mailer->new(%params);
}
