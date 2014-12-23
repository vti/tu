package Tu::ActionResponseResolver;

use strict;
use warnings;

use Carp qw(croak);
use Encode ();
use JSON   ();

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{encoding} = $params{encoding};
    $self->{encoding} = 'UTF-8' unless exists $params{encoding};

    return $self;
}

sub resolve {
    my $self = shift;
    my ($res, %options) = @_;

    return unless defined $res;

    if (!%options && (my $ref = ref $res)) {
        return $res if $ref eq 'ARRAY' || $ref eq 'CODE';

        return $res->finalize if $res->isa('Tu::Response');

        croak 'unexpected return from action';
    }

    my $type = $options{type} || 'html';

    my @headers;
    if ($type eq 'json') {
        @headers = ('Content-Type' => 'application/json');
        $res = JSON::encode_json($res);
    }
    elsif ($type eq 'html') {
        my $charset = '';
        if ($self->{encoding}) {
            $res = Encode::encode($self->{encoding}, $res);
            $charset = '; charset=' . lc($self->{encoding});
        }
        @headers = ('Content-Type' => "text/html$charset");
    }
    else {
        croak 'unexpected return option type';
    }

    @headers = @{$options{headers}} if $options{headers};

    my $status = $options{status} || $options{code} || 200;

    return [$status, [@headers], [$res]];
}

1;
