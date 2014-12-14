use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::X::HTTP;

subtest 'throws correct isa' => sub {
    isa_ok(
        exception {
            Tu::X::HTTP->throw('error', code => '500');
        },
        'Tu::X::HTTP'
    );
};

subtest 'returns code' => sub {
    my $e = exception {
        Tu::X::HTTP->throw('foo', code => '400');
    };

    is $e->code, 400;
};

subtest 'returns default code' => sub {
    my $e = exception {
        Tu::X::HTTP->throw('foo');
    };

    is $e->code, 500;
};

subtest 'supports stringification via as_string' => sub {
    my $e = exception {
        Tu::X::HTTP->throw('foo');
    };

    like $e->as_string, qr/foo/;
};

done_testing;
