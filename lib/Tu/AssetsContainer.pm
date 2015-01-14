package Tu::AssetsContainer;

use strict;
use warnings;

use Carp qw(croak);
use List::Util qw(first);
use File::Spec;

sub new {
    my $class = shift;
    my (%params) = @_;

    my $self = {};
    bless $self, $class;

    $self->{public_dir} = $params{public_dir};
    $self->{paths}      = [];

    return $self;
}

sub require {
    my $self = shift;
    my ($path, $type) = @_;

    return $self if first { $path eq $_->{path} } @{$self->{paths}};

    ($type) = $path =~ m/\.([^\.]+)$/ unless $type;

    push @{$self->{paths}}, {type => $type, path => $path};

    if (!ref($path) && (my $public_dir = $self->{public_dir})) {
        my $file = File::Spec->catfile($public_dir, $path);

        if (-e $file) {
            my $mtime = (stat($file))[9];

            $self->{paths}->[-1]->{v} = $mtime;
        }
    }

    return $self;
}

sub include {
    my $self = shift;
    my (%params) = @_;

    my @html;
    foreach my $asset (@{$self->{paths}}) {
        next if $params{type} && $asset->{type} ne $params{type};

        push @html, $self->_include_type($asset);
    }

    return join "\n", @html;
}

sub _include_type {
    my $self = shift;
    my ($options) = @_;

    my $path = $options->{path};
    my $type = $options->{type};

    my $v = '';
    $v = '?v=' . $options->{v} if $options->{v};

    if ($type eq 'js') {
        return qq|<script type="text/javascript">$$path</script>|
          if ref $path eq 'SCALAR';
        return qq|<script src="$path$v" type="text/javascript"></script>|;
    }
    elsif ($type eq 'css') {
        return qq|<link rel="stylesheet" href="$path$v" |
          . q|type="text/css" media="screen" />|;
    }
    else {
        croak "unknown asset type '$type'";
    }
}

1;
