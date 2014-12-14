use strict;
use warnings;

use Test::More;

use Tu::Validator::Compare;

subtest 'returns true when all same' => sub {
    my $rule = _build_rule();

    ok $rule->is_valid(['foo', 'foo', 'foo']);
};

subtest 'returns false when not same' => sub {
    my $rule = _build_rule();

    ok !$rule->is_valid(['foo', 'foo', 'bar']);
};

sub _build_rule {
    return Tu::Validator::Compare->new(@_);
}

done_testing;
