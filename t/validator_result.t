use strict;
use warnings;

use Test::More;

use Tu::ValidatorResult;

subtest 'returns true when no errors' => sub {
    my $result = _build_result();

    ok $result->is_success;
};

subtest 'returns false when errors' => sub {
    my $result = _build_result(errors => {foo => 'REQUIRED'});

    ok !$result->is_success;
};

subtest 'returns errors' => sub {
    my $result = _build_result(errors => {foo => 'REQUIRED'});

    is_deeply $result->errors, {foo => 'REQUIRED'};
};

subtest 'returns errors added manually' => sub {
    my $result = _build_result();

    $result->add_error(foo => 'REQUIRED');

    is_deeply $result->errors, {foo => 'REQUIRED'};
};

subtest 'returns mapped errors added manually' => sub {
    my $result = _build_result(messages => {REQUIRED => 'Required'});

    $result->add_error(foo => 'REQUIRED');

    is_deeply $result->errors, {foo => 'Required'};
};

subtest 'returns errors mapped' => sub {
    my $result = _build_result(
        messages =>
          {'foo.REQUIRED' => 'Foo is required', REQUIRED => 'Required'},
        errors => {foo => 'REQUIRED', bar => 'REQUIRED'}
    );

    is_deeply $result->errors, {foo => 'Foo is required', bar => 'Required'};
};

subtest 'returns all_params' => sub {
    my $result = _build_result(params => {foo => 'bar'});

    is_deeply $result->all_params, {foo => 'bar'};
};

subtest 'returns validated_params' => sub {
    my $result = _build_result(validated_params => {foo => 'bar'});

    is_deeply $result->validated_params, {foo => 'bar'};
};

sub _build_result { Tu::ValidatorResult->new(@_) }

done_testing;
