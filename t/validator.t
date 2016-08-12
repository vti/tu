use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu::Validator;

subtest 'throws when validated not a hash ref' => sub {
    my $validator = _build_validator();

    like exception { $validator->validate }, qr/must be a hash ref/;
};

subtest 'validates empty' => sub {
    my $validator = _build_validator();

    my $result = $validator->validate({});

    ok $result->is_success;
};

subtest 'throws when adding existing field' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    like exception { $validator->add_field('foo') }, qr/field 'foo' exists/;
};

subtest 'throws when adding rule to unknown field' => sub {
    my $validator = _build_validator();

    like exception { $validator->add_rule('foo') },
      qr/field 'foo' does not exist/;
};

subtest 'loads rule from custom namespace' => sub {
    my $validator = _build_validator(namespaces => ['Test::']);

    $validator->add_field('foo');
    $validator->add_rule('foo', 'custom');

    my $result = $validator->validate({foo => 'bar'});

    ok $result->is_success;
};

subtest 'possible to use several rules' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);
    $validator->add_rule('foo', 'regexp', qr/^[0-5]+$/);

    my $result = $validator->validate({foo => '3'});

    ok $result->is_success;
};

subtest 'throws when adding unknown field to group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    like exception { $validator->add_group_rule('rule', [qw/foo bar/]) },
      qr/field 'bar' does not exist/;
};

subtest 'throws when adding existing group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('rule', [qw/foo bar/], 'regexp');

    like exception { $validator->add_group_rule('rule') },
      qr/rule 'rule' exists/;
};

subtest 'require fields' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    my $result = $validator->validate({});

    ok !$result->is_success;
};

subtest 'require multiple fields' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    my $result = $validator->validate({foo => []});

    ok !$result->is_success;
};

subtest 'only one value is required when multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    my $result = $validator->validate({foo => ['', 2]});

    ok $result->is_success;
};

subtest 'empty values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    my $result = $validator->validate({foo => ''});

    ok !$result->is_success;
};

subtest 'multiple empty values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    my $result = $validator->validate({foo => ['', '']});

    ok !$result->is_success;
};

subtest 'only spaces' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    my $result = $validator->validate({foo => " 	\n"});

    ok !$result->is_success;
};

subtest 'multiple only spaces' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);

    my $result = $validator->validate({foo => [" 	\n", '   ']});

    ok !$result->is_success;
};

#subtest 'set required error to first value from multiple' => sub {
#    my $validator = _build_validator();
#
#    $validator->add_field('foo', multiple => 1);
#
#    my $result = $validator->validate({foo => []});
#
#    is_deeply($result->errors, {'foo[0]' => 'REQUIRED', foo => 'REQUIRED'});
#};

subtest 'not valid rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 'abc'});

    ok !$result->is_success;
};

subtest 'valid rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 123});

    ok $result->is_success;
};

subtest 'not return not valid values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 'abc'});

    is_deeply $result->validated_params, {};
};

subtest 'return valid values trimmed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => ' 123 '});

    is_deeply $result->validated_params, {foo => 123};
};

subtest 'return valid values not trimmed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', trim => 0);

    my $result = $validator->validate({foo => ' 123 '});

    is_deeply $result->validated_params, {foo => ' 123 '};
};

subtest 'return valid values not trimmed when references' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    my $result = $validator->validate({foo => {}});

    is_deeply $result->validated_params, {foo => {}};
};

subtest 'return valid values even when not valid' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 123});

    is_deeply $result->validated_params, {foo => 123};
};

subtest 'take first value' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => [123, 'bar']});

    is_deeply $result->validated_params, {foo => 123};
};

subtest 'check all values when multiple' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => [123, 'bar']});

    ok !$result->is_success;
};

subtest 'glue multiple values' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate(
        {'foo[0]' => '123', 'foo[1]' => '456', 'foo[2]' => [789, 123]});

    is_deeply $result->validated_params, {foo => [123, 456, 789]};
};

subtest 'add only one error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({});

    is_deeply $result->errors, {foo => 'REQUIRED'};
};

subtest 'no errors when field is optional' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => ''});

    ok $result->is_success;
};

subtest 'leave optional empty values' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => ''});

    is_deeply $result->validated_params, {foo => ''};
};

subtest 'leave optional multiple empty values' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo', multiple => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => ['', '']});

    is_deeply $result->validated_params, {foo => ['', '']};
};

subtest 'set default message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');

    my $result = $validator->validate({});

    is_deeply $result->errors, {foo => 'REQUIRED'};
};

subtest 'set global custom message' => sub {
    my $validator = _build_validator(messages => {'REQUIRED' => 'Required'});

    $validator->add_field('foo');

    my $result = $validator->validate({});

    is_deeply $result->errors, {foo => 'Required'};
};

subtest 'set prefixed custom message' => sub {
    my $validator = _build_validator(messages =>
          {'foo.REQUIRED' => 'Foo is required', REQUIRED => 'Required'});

    $validator->add_field('foo');
    $validator->add_field('bar');

    my $result = $validator->validate({});

    is_deeply $result->errors, {foo => 'Foo is required', bar => 'Required'};
};

subtest 'set rule default message' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 'bar'});

    is_deeply $result->errors, {foo => 'REGEXP'};
};

subtest 'validate group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    my $result = $validator->validate({foo => 'baz', bar => 'baz'});

    ok $result->is_success;
};

subtest 'validate invalid group rule' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    my $result = $validator->validate({foo => 'baz', bar => '123'});

    ok !$result->is_success;
};

subtest 'set group error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');
    $validator->add_group_rule('fields', [qw/foo bar/], 'compare');

    my $result = $validator->validate({foo => 'baz', bar => '123'});

    is_deeply $result->errors, {fields => 'COMPARE'};
};

subtest 'returns all params' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar');

    my $result = $validator->validate({foo => 'baz', bar => '123'});

    is_deeply $result->all_params, {foo => 'baz', bar => '123'};
};

subtest 'returns all params preprocessed' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar', multiple => 1);

    my $result = $validator->validate({foo => ['baz'], bar => '123'});

    is_deeply $result->all_params, {foo => 'baz', bar => ['123']};
};

subtest 'not modify passed params' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo');
    $validator->add_field('bar', multiple => 1);

    my $params = {foo => ['baz'], bar => '123'};
    $validator->validate($params);

    is_deeply $params, {foo => ['baz'], bar => '123'};
};

subtest 'sets default value when empty' => sub {
    my $validator = _build_validator();

    $validator->add_optional_field('foo', default => '1');
    $validator->add_optional_field('bar', default => '2');
    $validator->add_optional_field('baz', default => '3');
    $validator->add_field('required', default => '4');

    my $result = $validator->validate({bar => undef, baz => ''});

    ok $result->is_success;
    is $result->validated_params->{foo}, '1';
    is $result->validated_params->{bar}, '2';
    is $result->validated_params->{baz}, '3';
    is $result->validated_params->{required}, '4';
};

subtest 'does not set default when not empty' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', default => '1');

    my $result = $validator->validate({foo => '2'});

    ok $result->is_success;
    is $result->validated_params->{foo}, '2';
};

subtest 'sets default value on error' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', default => '1', default_on_error => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 'bar'});

    ok $result->is_success;
    is $result->validated_params->{foo}, '1';
};

subtest 'does not set default when valid' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', default => '1', default_on_error => 1);
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => '2'});

    ok $result->is_success;
    is $result->validated_params->{foo}, '2';
};

subtest 'does not set default when invalid' => sub {
    my $validator = _build_validator();

    $validator->add_field('foo', default => '1');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    my $result = $validator->validate({foo => 'foo'});

    ok !$result->is_success;
    ok !exists $result->validated_params->{foo};
};

sub _build_validator { Tu::Validator->new(@_) }

done_testing;

package Test::Custom;
use parent 'Tu::Validator::Regexp';

sub is_valid {
    my $class = shift;
    my ($value) = @_;

    return 1 if $value eq 'bar';
    return 0;
}

1;
