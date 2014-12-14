use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Env;

subtest 'get values' => sub {
    my $env = _build_env();

    $env->register('dispatched_request' => 'bar');

    #$env->set(dispatched_request => 'bar');

    is $env->dispatched_request, 'bar';
};

#subtest 'multi values' => sub {
#    my $env = _build_env();
#
#    $env->register('displayer', multi => [qw/vars layout/]);
#
#    $env->set('displayer.vars', {});
#    $env->displayer('vars')->{foo} = 'bar';
#
#    is_deeply $env->displayer('vars'), {foo => 'bar'};
#    is_deeply $env->displayer, {vars => {foo => 'bar'}};
#};
#
#subtest 'low level set and get values' => sub {
#    my $env = _build_env();
#
#    $env->register('dispatched_request');
#
#    $env->set(dispatched_request => 'foo');
#
#    is_deeply $env->get('dispatched_request'), 'foo';
#};

subtest 'throw when registering registered key' => sub {
    my $env = _build_env();

    $env->register('displayer.vars');

    like exception { $env->register('displayer.vars') },
      qr/key 'displayer\.vars' already registered/;
};

subtest 'throw on unknown key' => sub {
    my $env = _build_env();

    like exception { $env->get('foo') },
      qr/unknown key 'foo'/;
};

sub _build_env {
    my $env = {};
    Tu::Env->new($env);
}

done_testing;
