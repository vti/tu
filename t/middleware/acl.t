use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::ACL;
use Tu::DispatchedRequest;
use Tu::Middleware::ACL;

subtest 'allows when role is correct' => sub {
    my $mw = _build_middleware();

    my $env = _build_env(user_role => 'user', action => 'foo');

    my $res = $mw->prepare_app->call($env);

    ok $res;
};

subtest 'denies when unknown role' => sub {
    my $mw = _build_middleware();

    ok exception {
        $mw->prepare_app->call(
            _build_env(user_role => 'admin', action => 'bar'));
    };
};

subtest 'denies when denied action' => sub {
    my $mw = _build_middleware();

    ok exception {
        $mw->prepare_app->call(
            _build_env(user_role => 'user', action => 'bar'));
    };
};

subtest 'denies when no role' => sub {
    my $mw = _build_middleware();

    ok exception { $mw->prepare_app->call({}) };
};

subtest 'redirects instead of throw' => sub {
    my $mw = _build_middleware(redirect_to => '/login');

    my $res = $mw->prepare_app->call({PATH_INFO => '/'});

    is_deeply $res, [302, ['Location' => '/login'], ['']];
};

subtest 'prevents redirect recursion' => sub {
    my $mw = _build_middleware(redirect_to => '/login');

    ok exception {
        $mw->prepare_app->call({PATH_INFO => '/login', 'tu.user_role' => undef})
    };
};

sub _build_middleware {
    my $acl = Tu::ACL->new;

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    return Tu::Middleware::ACL->new(
        app => sub { [200, [], ['OK']] },
        acl => $acl,
        @_
    );
}

sub _build_env {
    my %params = @_;

    my $action = delete $params{action};

    my $env = {};

    $env->{'tu.user_role'} = undef;
    $env->{'tu.dispatched_request'} =
      Tu::DispatchedRequest->new(action => $action);

    foreach my $key (keys %params) {
        $env->{"tu.$key"} = $params{$key};
    }

    return $env;
}

done_testing;
