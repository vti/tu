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

    if (my $ref = ref $res) {
        return $res if $ref eq 'ARRAY' || $ref eq 'CODE';

        return $res->finalize if $res->isa('Tu::Response');

        croak 'unexpected return from action';
    }

    my $charset = '';
    if ($self->{encoding}) {
        $res = Encode::encode($self->{encoding}, $res);
        $charset = '; charset=' . lc($self->{encoding});
    }

    return [200, ['Content-Type' => "text/html$charset"], [$res]];
}

1;
