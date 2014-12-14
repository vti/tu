use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Dispatcher::Routes;
use Tu::Routes;

subtest 'throws on unknown action' => sub {
    my $d = _build_dispatcher();

    like(exception { $d->dispatch('/unknown/action') }, qr/action is unknown/i);
};

subtest 'returns action from name' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/');

    is($dispatched->action, 'root');
};

subtest 'returns action from capture' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo');

    is($dispatched->action, 'foo');
};

subtest 'returns captures' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo');

    is_deeply $dispatched->captures, {action => 'foo'};
};

subtest 'builds path' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo');

    is($dispatched->build_path('root'), '/');
};

subtest 'returns undef when not matched' => sub {
    my $d = _build_dispatcher();

    my $dispatched = $d->dispatch('/foo/bar/baz');

    ok !$dispatched;
};

sub _build_dispatcher {
    my $routes = Tu::Routes->new;
    $routes->add_route('/', name => 'root');
    $routes->add_route('/:action');
    $routes->add_route('/unknown/action');

    Tu::Dispatcher::Routes->new(routes => $routes);
}

done_testing;
