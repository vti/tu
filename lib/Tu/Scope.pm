package Tu::Scope;

use strict;
use warnings;

use Carp 'croak';

sub new {
    my $class = shift;
    my ($env) = @_;

    croak '$env required' unless $env;

    my $self = {env => $env};
    bless $self, $class;

    return $self;
}

sub set {
    my $self = shift;
    my ($key, $value) = @_;

    return $self->{env}->{"tu.$key"} = $value;
}

sub exists : method {
    my $self = shift;
    my ($key) = @_;

    return $self->_key_exists($key);
}

sub get {
    my $self = shift;
    my ($key) = @_;

    my @subkeys = grep { /^tu\.$key\./ } keys %{$self->{env}};
    if (@subkeys) {
        s/^tu\.$key\.// for @subkeys;

        my $new_env = {};
        $new_env->{"tu.$_"} = $self->{env}->{"tu.$key.$_"} for @subkeys;

        return __PACKAGE__->new($new_env);
    }

    croak "unknown key '$key'"
      unless my $options = $self->_key_exists($key);

    return $self->{env}->{"tu.$key"};
}

sub _key_exists {
    my $self = shift;
    my ($key) = @_;

    return exists $self->{env}->{"tu.$key"};
}

sub DESTROY { }

our $AUTOLOAD;

sub AUTOLOAD {
    my $self = shift;

    my ($method) = (split /::/, $AUTOLOAD)[-1];

    return if $method =~ /^[A-Z]/;
    return if $method =~ /^_/;

    return $self->get($method, @_);
}

1;
