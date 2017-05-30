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
    my ($path, %options) = @_;

    return $self if first { $path eq $_->{path} } @{$self->{paths}};

    my $type = $options{type};
    ($type) = $path =~ m/\.([^\.]+)$/ unless $type;

    push @{$self->{paths}}, {%options, type => $type, path => $path};

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

    my @assets = @{$self->{paths}};

    if (my $type = $params{type}) {
        @assets = grep { $_->{type} && $_->{type} eq $type } @assets;
    }

    @assets = sort { ($a->{index} || 999) <=> ($b->{index} || 999) } @assets;

    my @html;
    foreach my $asset (@assets) {
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

    my $attrs = '';
    if ($options->{attrs} && %{$options->{attrs}}) {
        $attrs = ' '
          . join(' ',
            map { qq{$_="$options->{attrs}->{$_}"} } keys %{$options->{attrs}});
    }

    if ($type eq 'js') {
        return qq|<script type="text/javascript"$attrs>$$path</script>|
          if ref $path eq 'SCALAR';
        return qq|<script src="$path$v" type="text/javascript"$attrs></script>|;
    }
    elsif ($type eq 'css') {
        return qq|<link rel="stylesheet" href="$path$v" |
          . qq|type="text/css" media="screen"$attrs />|;
    }
    else {
        croak "unknown asset type '$type'";
    }
}

1;
