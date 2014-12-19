use strict;
use warnings;

use Test::More;
use File::Temp;
use HTTP::Request::Common;
use HTTP::Message::PSGI;
use Tu::Validator;

subtest 'do nothing on get' => sub {
    my $action = _build_form('TestForm', GET '/');

    ok !defined $action->run;
};

subtest 'validate on POST' => sub {
    my $action = _build_form('TestForm', POST '/');

    ok !defined $action->run;

    is_deeply $action->vars->{errors}, {foo => 'REQUIRED'};
};

subtest 'sets params on errors' => sub {
    my $action = _build_form('TestForm', POST '/', {foo => 'wrong'});

    $action->run;

    is_deeply $action->vars->{params}, {foo => 'wrong'};
};

subtest 'calls submit on success' => sub {
    my $action = _build_form('TestForm', POST '/', {foo => 123});

    is $action->run, 'SUBMIT 123';

    is_deeply $action->vars, {};
};

subtest 'calls show when present' => sub {
    my $action = _build_form('TestFormWithShow', GET '/');

    is $action->run, 'SHOW';
};

subtest 'calls show on errors when present' => sub {
    my $action = _build_form('TestFormWithShow', POST '/');

    is $action->run, 'SHOW';
};

subtest 'calls custom validation' => sub {
    my $action =
      _build_form('TestFormWithCustomValidation', POST '/', {foo => 123});

    $action->run;

    is_deeply $action->vars->{errors}, {foo => 'too big'};
};

subtest 'runs submit when passing custom validation' => sub {
    my $action =
      _build_form('TestFormWithCustomValidation', POST '/', {foo => 1});

    is $action->run, 'ok';

    is_deeply $action->vars, {};
};

subtest 'validates uploads' => sub {
    my $fh     = File::Temp->new;
    my $action = _build_form(
        'TestFormWithUploads',
        POST '/',
        Content_Type => 'multipart/form-data',
        Content      => [upload => [$fh->filename]]
    );

    is $action->run, 'ok';

    is_deeply $action->vars, {};
};

done_testing;

sub _build_form {
    my ($class, $req) = @_;

    my $env = req_to_psgi($req);

    $env->{'tu.displayer.vars'} = {};

    return $class->new(env => $env);
}

package TestForm;
use base 'Tu::Action';

use Tu::Action::FormMixin 'validate_or_submit';

sub build_validator {
    my $validator = Tu::Validator->new;

    $validator->add_field('foo');
    $validator->add_rule('foo', 'regexp', qr/^\d+$/);

    return $validator;
}

sub submit {
    my $self = shift;
    my ($params) = @_;
    'SUBMIT ' . $params->{foo};
}

sub run { shift->validate_or_submit }

package TestFormWithShow;
use base 'Tu::Action';

use Tu::Action::FormMixin 'validate_or_submit';

sub build_validator {
    my $validator = Tu::Validator->new;
    $validator->add_field('foo');
}

sub show { 'SHOW' }

sub submit { }

sub run { shift->validate_or_submit }

package TestFormWithCustomValidation;
use base 'Tu::Action';

use Tu::Action::FormMixin 'validate_or_submit';

sub build_validator {
    my $validator = Tu::Validator->new;
    $validator->add_field('foo');
    return $validator;
}

sub submit { 'ok' }

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    if (length $params->{foo} > 1) {
        $validator->add_error('foo', 'too big');
        return 0;
    }

    return 1;
}

sub run { shift->validate_or_submit }

package TestFormWithUploads;
use base 'Tu::Action';

use Tu::Action::FormMixin 'validate_or_submit';

sub build_validator {
    my $validator = Tu::Validator->new;
    $validator->add_field('upload');
    return $validator;
}

sub submit { 'ok' }

sub validate {
    my $self = shift;
    my ($validator, $params) = @_;

    if (length $params->{upload} > 128) {
        $validator->add_error('foo', 'too big');
        return 0;
    }

    return 1;
}

sub run { shift->validate_or_submit }
