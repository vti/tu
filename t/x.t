use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::X::Base;

subtest 'stringifies' => sub {
    my $e = exception { Tu::X::Base->throw('hi there') };

    is $e, 'hi there at t/x.t line 10.';
};

subtest 'returns message' => sub {
    my $e = exception { Tu::X::Base->throw('hi there') };

    is $e->message, 'hi there';
};

subtest 'returns exception class when no message was passed' => sub {
    my $e = exception { Tu::X::Base->throw };

    like $e, qr/Exception: Tu::X::Base /;
};

done_testing;
