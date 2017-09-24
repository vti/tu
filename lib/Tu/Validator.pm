package Tu::Validator;

use strict;
use warnings;

use Carp qw(croak);
use Tu::Loader;
use Tu::ValidatorResult;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{messages}   = $params{messages};
    $self->{namespaces} = $params{namespaces};

    $self->{messages}   ||= {};
    $self->{namespaces} ||= ['Tu::Validator::'];

    $self->{fields} = {};
    $self->{rules}  = {};

    return $self;
}

sub add_field {
    my $self = shift;
    my ($field, %params) = @_;

    croak "field '$field' exists"
      if exists $self->{fields}->{$field};

    $self->{fields}->{$field} = {required => 1, trim => 1, %params};

    return $self;
}

sub add_optional_field { shift->add_field(@_, required => 0) }

sub add_rule {
    my $self = shift;
    my ($field_name, $rule_name, @rule_args) = @_;

    croak "field '$field_name' does not exist"
      unless exists $self->{fields}->{$field_name};

    my $rule = $self->_build_rule(
        $rule_name,
        fields => [$field_name],
        args   => \@rule_args
    );

    push @{$self->{rules}->{$field_name}}, $rule;

    return $rule;
}

sub add_group_rule {
    my $self = shift;
    my ($group_name, $fields_names, $rule_name, @rule_args) = @_;

    for my $field_name (@$fields_names) {
        croak "field '$field_name' does not exist"
          unless exists $self->{fields}->{$field_name};
    }

    croak "rule '$group_name' exists"
      if exists $self->{rules}->{$group_name};

    my $rule = $self->_build_rule(
        $rule_name,
        fields => $fields_names,
        args   => \@rule_args
    );

    push @{$self->{rules}->{$group_name}}, $rule;

    return $self;
}

sub validate {
    my $self = shift;
    my ($params) = @_;

    croak 'must be a hash ref' unless ref $params eq 'HASH';

    $params = $self->_prepare_params($params);

    my $result = {params => $params};

    $self->_validate_required($result);

    $self->_validate_rules($result);

    $result->{validated_params} = $self->_gather_validated_params($result);

    return Tu::ValidatorResult->new(%$result, messages => $self->{messages});
}

sub _validate_required {
    my $self = shift;
    my ($result) = @_;

    foreach my $name (keys %{$self->{fields}}) {
        my $value = $result->{params}->{$name};

        my $is_empty = $self->_is_field_empty($value);

        if ($is_empty) {
            if (exists $self->{fields}->{$name}->{default}) {
                $result->{params}->{$name} = $self->{fields}->{$name}->{default};
            }
            elsif ($self->{fields}->{$name}->{required}) {
                $result->{errors}->{$name} = 'REQUIRED';
            }
        }
    }
}

sub _validate_rules {
    my $self = shift;
    my ($result) = @_;

    my $params = $result->{params};

    foreach my $rule_name (keys %{$self->{rules}}) {
        next if exists $self->{errors}->{$rule_name};

        if (exists $self->{fields}->{$rule_name}) {
            next if $self->_is_field_empty($params->{$rule_name});
        }

        my $rules = $self->{rules}->{$rule_name};

        foreach my $rule (@$rules) {
            next if $rule->validate($params);

            if (exists $self->{fields}->{$rule_name}
                && $self->{fields}->{$rule_name}->{default_on_error})
            {
                $params->{$rule_name} =
                  $self->{fields}->{$rule_name}->{default};
                last;
            }

            $result->{errors}->{$rule_name} = $rule->name;
            last;
        }
    }
}

sub _gather_validated_params {
    my $self = shift;
    my ($result) = @_;

    my $validated_params = {};

    foreach my $name (keys %{$self->{fields}}) {
        next if exists $result->{errors}->{$name};

        if (exists $result->{params}->{$name}) {
            my $value = $result->{params}->{$name};

            $validated_params->{$name} = length $value ? $value : undef;
        }
    }

    return $validated_params;
}

sub _is_field_empty {
    my $self = shift;
    my ($value) = @_;

    $value = [$value] unless ref $value eq 'ARRAY';
    return 1 unless @$value;

    my $all_empty = 1;

    foreach (@$value) {
        if (defined $_ && $_ ne '') {
            $all_empty = 0;
            last;
        }
    }

    return $all_empty;
}

sub _prepare_params {
    my $self = shift;
    my ($params) = @_;

    $params = $self->_prepare_array_like($params);

    foreach my $name (keys %{$self->{fields}}) {
        if ($self->{fields}->{$name}->{multiple}) {
            $params->{$name} = [$params->{$name}]
              unless ref $params->{$name} eq 'ARRAY';
        }
        else {
            $params->{$name} = $params->{$name}->[0]
              if ref $params->{$name} eq 'ARRAY';
        }

        $params->{$name} = $self->_trim($params->{$name})
          if $self->{fields}->{$name}->{trim};
    }

    return $params;
}

sub _prepare_array_like {
    my $self = shift;
    my ($params) = @_;

    my $prepared = {};
    foreach my $key (keys %$params) {
        my $value = $params->{$key};
        $value = [@$value] if ref $value eq 'ARRAY';

        if ($key =~ m/^(.*?)\[(\d+)\]$/) {
            my ($name, $index) = ($1, $2);

            $prepared->{$name}->[$index] =
              ref $value eq 'ARRAY' ? $value->[0] : $value;
        }
        else {
            $prepared->{$key} = $value;
        }
    }

    return $prepared;
}

sub _trim {
    my $self = shift;
    my ($param) = @_;

    foreach my $param (ref $param eq 'ARRAY' ? @$param : $param) {
        next if !defined $param || ref $param;
        for ($param) { s/^\s*//g; s/\s*$//g; }
    }

    return $param;
}

sub _build_rule {
    my $self = shift;
    my ($rule_name, @args) = @_;

    my $rule_class =
      Tu::Loader->new(namespaces => $self->{namespaces})
      ->load_class(ucfirst $rule_name);

    return $rule_class->new(@args);
}

1;
