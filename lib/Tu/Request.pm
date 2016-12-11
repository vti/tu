package Tu::Request;

use strict;
use warnings;

use parent 'Plack::Request';

use Encode ();

use Tu::Response;

sub new {
    my $class = shift;
    my ($env, %options) = @_;

    my $self = $class->SUPER::new($env);

    $self->{encoding} = $options{encoding} ||= 'UTF-8';

    return $self;
}

sub new_response {
    my $self = shift;

    return Tu::Response->new(@_);
}

sub _query_parameters { shift->_decode_parameters('query_parameters', @_) }
sub _body_parameters  { shift->_decode_parameters('body_parameters',  @_) }

sub _decode_parameters {
    my $self = shift;
    my ($request_key, @args) = @_;

    my $method = "SUPER::_$request_key";

    my $super = $self->$method(@args);

    my $params = $self->env->{"plack.request.$request_key"};

    my $encoding = $self->{encoding};
    foreach my $key (@$params) {
        $key = Encode::decode($encoding, $key);
    }

    return $self->env->{"plack.request.$request_key"} = $params;
}

1;
