package Tu::Config::Yml;

use strict;
use warnings;

use Encode ();
use YAML::Tiny;
use constant HAVE_YAML_XS => eval { require YAML::XS };

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub parse {
    my $self = shift;
    my ($config) = @_;

    if (HAVE_YAML_XS) {
        $config = Encode::encode('UTF-8', $config) if Encode::is_utf8($config);

        $config = YAML::XS::Load($config);
    }
    else {
        $config = YAML::Tiny->read_string($config);
        $config = $config->[0];
    }

    return $config || {};
}

1;
