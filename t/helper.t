use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::Helper;

subtest 'returns empty hash ref' => sub {
    my $env = {'tu.displayer.vars' => {}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->params, {};
};

subtest 'returns params' => sub {
    my $env = {'tu.displayer.vars' => {params => {foo => 'bar'}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->params, {foo => 'bar'};
};

subtest 'returns param' => sub {
    my $env = {'tu.displayer.vars' => {params => {foo => 'bar'}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param('foo'), 'bar';
};

subtest 'returns param if array ref' => sub {
    my $env = {'tu.displayer.vars' => {params => {foo => ['bar', 'baz']}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param('foo'), 'bar';
};

subtest 'returns all params when single' => sub {
    my $env = {'tu.displayer.vars' => {params => {foo => 'bar'}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param_multi('foo'), ['bar'];
};

subtest 'returns all params when array ref' => sub {
    my $env = {'tu.displayer.vars' => {params => {foo => ['bar', 'baz']}}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param_multi('foo'), ['bar', 'baz'];
};

subtest 'returns empty arrray ref on multi' => sub {
    my $env = {'tu.displayer.vars' => {}};
    my $helper = _build_helper(env => $env);

    is_deeply $helper->param_multi('unknown'), [];
};

sub _build_helper {
    my $services = Test::MonkeyMock->new;
    Tu::Helper->new(services => $services, @_);
}

done_testing;
