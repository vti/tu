use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;
use Test::Fatal;

use Tu::Plugins;

subtest 'registers plugin' => sub {
    my $builder = _mock_builder();
    my $plugins = _build_plugins(builder => $builder);

    $plugins->register('TestPlugin');

    my ($name) = $builder->mocked_call_args('add_middleware');

    is $name, 'Foo';
};

subtest 'throws when registering registered plugin' => sub {
    my $plugins = _build_plugins();

    $plugins->register('TestPlugin');

    like exception { $plugins->register('TestPlugin') },
      qr/plugin 'TestPlugin' already registered/;
};

sub _mock_builder {
    my $builder = Test::MonkeyMock->new;
    $builder->mock(add_middleware => sub { });
}

sub _mock_services {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { });
}

sub _build_plugins {
    my (%params) = @_;

    $params{builder}  ||= _mock_builder();
    $params{services} ||= _mock_services();

    return Tu::Plugins->new(%params);
}

done_testing;

package TestPlugin;
use base 'Tu::Plugin';

sub startup {
    my $self = shift;

    $self->builder->add_middleware('Foo');
}
