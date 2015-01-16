package Tu::ActionResponseResolver;

use strict;
use warnings;

use Carp qw(croak);
use Encode ();

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
    my ($res) = @_;

    return unless defined $res;

    unless (ref $res) {
        my $charset = '';

        if (my $encoding = $self->{encoding}) {
            $res = Encode::encode($encoding, $res);
            $charset = '; charset=' . lc($charset);
        }

        return [
            200,
            ['Content-Type' => "text/html$charset", 'Content-Length' => $res],
            [$res]
        ];
    }

    return $res if ref $res eq 'ARRAY' || ref $res eq 'CODE';

    return $res->finalize if $res->isa('Tu::Response');

    croak 'unexpected return from action';
}

1;
