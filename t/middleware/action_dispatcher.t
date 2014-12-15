use strict;
use warnings;

use lib 't/middleware/action_dispatcher_t';

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Tu::DispatchedRequest;
use Tu::ActionFactory;
use Tu::Middleware::ActionDispatcher;

subtest 'throws when no action_factory' => sub {
    like exception {
        _build_middleware(action_factory => undef)
    }, qr/action_factory required/;
};

subtest 'does nothing when no action' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env());

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'does nothing when unknown action' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'unknown'));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'skips when no response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'no_response'));

    is_deeply($res, [200, [], ['OK']]);
};

subtest 'runs action with custom response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'custom_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Custom response!']];
};

subtest 'runs action with text response' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(_build_env(action => 'text_response'));

    is_deeply $res =>
      [200, ['Content-Type' => 'text/html'], ['Text response!']];
};

sub _build_env {
    my (%params) = @_;

    my $env =
      {'tu.dispatched_request' =>
          Tu::DispatchedRequest->new(action => delete $params{action})};

    foreach my $key (keys %params) {
        if ($key =~ m/^tu/) {
            $env->{$key} = $params{$key};
        }
        else {
            $env->{"tu.$key"} = $params{$key};
        }
    }

    return $env;
}

sub _mock_services {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { });
}

sub _build_middleware {
    my (%params) = @_;

    $params{services} ||= _mock_services();

    return Tu::Middleware::ActionDispatcher->new(
        action_factory => Tu::ActionFactory->new(),
        app            => sub { [200, [], ['OK']] },
        %params
    );
}

done_testing;
