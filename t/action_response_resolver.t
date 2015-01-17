use strict;
use warnings;
use utf8;

use Test::More;
use Test::Fatal;

use Encode ();

use Tu::Response;
use Tu::ActionResponseResolver;

subtest 'returns undef on undef' => sub {
    my $resolver = _build_resolver();

    ok !defined $resolver->resolve;
};

subtest 'returns array ref as is' => sub {
    my $resolver = _build_resolver();

    is_deeply $resolver->resolve([200, [], ['body']]), [200, [], ['body']];
};

subtest 'returns code as is' => sub {
    my $resolver = _build_resolver();

    is ref $resolver->resolve(sub { }), 'CODE';
};

subtest 'returns finalized object' => sub {
    my $resolver = _build_resolver();

    is_deeply $resolver->resolve(Tu::Response->new(200)),
      [200, ['Content-Type' => 'text/html'], []];
};

subtest 'returns string' => sub {
    my $resolver = _build_resolver();

    is_deeply $resolver->resolve('hello world'),
      [
        200,
        ['Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => 11],
        ['hello world']
      ];
};

subtest 'returns encoded string' => sub {
    my $resolver = _build_resolver();

    is_deeply $resolver->resolve('привет'),
      [
        200,
        ['Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => 12],
        [Encode::encode('UTF-8', 'привет')]
      ];
};

subtest 'throws when unexpected return type' => sub {
    my $resolver = _build_resolver();

    like exception { $resolver->resolve(TestObject->new) },
      qr/unexpected return from action/;
};

sub _build_resolver { Tu::ActionResponseResolver->new(@_) }

done_testing;

package TestObject;

use strict;
use warnings;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

1;
