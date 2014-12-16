use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Scope;

subtest 'throws when no env' => sub {
    like exception { Tu::Scope->new }, qr/\$env required/;
};

subtest 'returns true if key exists' => sub {
    my $scope = _build_scope();

    $scope->set('dispatched_request' => 'bar');

    ok $scope->exists('dispatched_request');
};

subtest 'returns false when key does not exist' => sub {
    my $scope = _build_scope();

    ok !$scope->exists('dispatched_request');
};

subtest 'sets value' => sub {
    my $scope = _build_scope();

    $scope->set('dispatched_request' => 'bar');

    is $scope->dispatched_request, 'bar';
};

subtest 'returns set value' => sub {
    my $scope = _build_scope();

    is $scope->set('dispatched_request' => 'bar'), 'bar';
};

subtest 'sets multi values' => sub {
    my $scope = _build_scope();

    $scope->set('displayer.vars' => {foo => 'bar'});
    $scope->set('displayer.layout'   => 'layout.tpl');
    $scope->set('displayer.template' => 'template');

    is_deeply $scope->displayer->vars, {foo => 'bar'};
    is $scope->displayer->layout,   'layout.tpl';
    is $scope->displayer->template, 'template';
};

subtest 'works with existing env' => sub {
    my $scope = _build_scope(env => {'tu.displayer.vars' => {foo => 'bar'}});

    is_deeply $scope->displayer->vars, {foo => 'bar'};
};

subtest 'throw on unknown key' => sub {
    my $scope = _build_scope();

    like exception { $scope->get('foo') }, qr/unknown key 'foo'/;
};

sub _build_scope {
    my (%params) = @_;

    my $env = $params{env} || {};
    Tu::Scope->new($env);
}

done_testing;
