package Tu::Action::FormMixin;

use strict;
use warnings;

use parent 'Exporter';

our @EXPORT_OK = qw(validate_or_submit);

sub validate_or_submit {
    my $self = shift;

    if ($self->req->method eq 'GET') {
        return $self->show if $self->can('show');
        return;
    }

    my $params = $self->req->parameters->as_hashref_mixed;
    $params = {%$params, %{$self->req->uploads->as_hashref_mixed || {}}};

    my $result = $self->build_validator->validate($params);

    my $ok = $result->is_success;

    if ($result->is_success && $self->can('validate')) {
        $ok = $self->validate($result, $result->validated_params);
    }

    if ($ok) {
        return $self->submit($result->validated_params);
    }

    $self->set_var(errors => $result->errors);
    $self->set_var(params => $result->all_params);

    return $self->show if $self->can('show');
    return;
}

1;
