use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Exception::HTTP;

subtest 'throws correct isa' => sub {
    isa_ok(
        exception {
            Tu::Exception::HTTP->throw('error', code => '500');
        },
        'Tu::Exception::HTTP'
    );
};

subtest 'returns code' => sub {
    my $e = exception {
        Tu::Exception::HTTP->throw('foo', code => '400');
    };

    is $e->code, 400;
};

subtest 'returns default code' => sub {
    my $e = exception {
        Tu::Exception::HTTP->throw('foo');
    };

    is $e->code, 500;
};

subtest 'supports stringification via as_string' => sub {
    my $e = exception {
        Tu::Exception::HTTP->throw('foo');
    };

    like $e->as_string, qr/foo/;
};

done_testing;
