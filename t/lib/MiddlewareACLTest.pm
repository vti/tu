package MiddlewareACLTest;

use strict;
use warnings;

use base 'TestBase';

use Test::More;
use Test::Fatal;

use Turnaround::ACL;
use Turnaround::DispatchedRequest;
use Turnaround::Middleware::ACL;

sub allow_when_role_is_correct : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    my $env = $self->_build_env(user => {role => 'user'}, action => 'foo');

    my $res = $mw->call($env);

    ok($res);
}

sub deny_when_unknown_role : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    ok( exception {
            $mw->call(
                $self->_build_env(user => {role => 'anon'}, action => 'bar'));
        }
    );
}

sub deny_when_denied_action : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    ok( exception {
            $mw->call(
                $self->_build_env(user => {role => 'user'}, action => 'bar'));
        }
    );
}

sub deny_when_no_user : Test {
    my $self = shift;

    my $mw = $self->_build_middleware;

    ok(exception { $mw->call({}) });
}

sub redirect_instead_of_throw : Test {
    my $self = shift;

    my $mw = $self->_build_middleware(redirect_to => '/login');

    my $res = $mw->call({PATH_INFO => '/'});

    is_deeply($res, [302, ['Location' => '/login'], ['']]);
}

sub prevent_redirect_recursion : Test {
    my $self = shift;

    my $mw = $self->_build_middleware(redirect_to => '/login');

    ok(exception { $mw->call({PATH_INFO => '/login'}) });
}

sub _build_middleware {
    my $self = shift;

    my $acl = Turnaround::ACL->new;

    $acl->add_role('user');
    $acl->allow('user', 'foo');

    return Turnaround::Middleware::ACL->new(
        app => sub { [200, [], ['OK']] },
        acl => $acl,
        @_
    );
}

sub _build_env {
    my $self   = shift;
    my %params = @_;

    my $action = delete $params{action};

    my $env = {};

    $env->{'turnaround.dispatched_request'} =
      Turnaround::DispatchedRequest->new(action => $action);

    foreach my $key (keys %params) {
        $env->{"turnaround.$key"} = $params{$key};
    }

    return $env;
}

1;
