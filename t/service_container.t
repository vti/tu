use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Scalar::Util qw(blessed);
use Tu::ServiceContainer;

subtest 'throws on getting unknown service' => sub {
    my $c = _build_container();

    like exception { $c->service('foo') }, qr/unknown service 'foo'/;
};

subtest 'throws on registering already registered service' => sub {
    my $c = _build_container();

    $c->register(foo => 'bar');

    like exception { $c->register(foo => 'baz') },
      qr/service 'foo' already registered/;
};

subtest 'returns true when service registered' => sub {
    my $c = _build_container();

    $c->register(foo => 'bar');

    ok $c->is_registered('foo');
};

subtest 'returns false when service not registered' => sub {
    my $c = _build_container();

    ok !$c->is_registered('foo');
};

subtest 'registers scalar service' => sub {
    my $c = _build_container();

    $c->register(foo => 'bar');

    is $c->service('foo'), 'bar';
};

subtest 'registers instance service' => sub {
    my $c = _build_container();

    $c->register(foo => FooInstance->new);

    isa_ok($c->service('foo'), 'FooInstance');
};

subtest 'registers service via sub' => sub {
    my $c = _build_container();

    $c->register(foo => sub { 'foo' });

    is($c->service('foo'), 'foo');
};

subtest 'registers service as a class' => sub {
    my $c = _build_container();

    $c->register(foo => 'FooInstance', new => 1);

    ok blessed $c->service('foo');
    isa_ok($c->service('foo'), 'FooInstance');
};

subtest 'registers service as a class with deps' => sub {
    my $c = _build_container();

    $c->register(bar => 'bar');
    $c->register(foo => 'FooInstance', new => [qw/bar/]);

    is $c->service('foo')->{bar}, 'bar';
};

subtest 'overwrites registered service' => sub {
    my $c = _build_container();

    $c->register(bar => 'bar');

    ok !exception { $c->overwrite(bar => 'baz') };
};

subtest 'overwrites registered with previous params' => sub {
    my $c = _build_container();

    $c->register(foo => 'FooInstance', new => 1);

    $c->overwrite(foo => 'FooInstance');

    ok blessed $c->service('foo');
};

subtest 'creates instance with custom construction' => sub {
    my $c = _build_container();

    $c->register(bar => 'bar');
    $c->register(
        foo => 'FooInstance',
        new => sub {
            my ($class, $services) = @_;

            $class->new(custom => $services->service('bar'));
        }
    );

    is $c->service('foo')->{custom}, 'bar';
};

sub _build_container { Tu::ServiceContainer->new(@_) }

done_testing;

package FooInstance;

sub new {
    my $class = shift;

    my $self = {@_};
    bless $self, $class;

    return $self;
}

1;
