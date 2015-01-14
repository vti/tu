package Tu::Helper::Assets;

use strict;
use warnings;

use parent 'Tu::Helper';

use Tu::AssetsContainer;

sub include {
    my $self = shift;

    return $self->_container->include(@_);
}

sub require {
    my $self = shift;

    $self->_container->require(@_);

    return $self;
}

sub _container {
    my $self = shift;

    my $home = $self->service('home');
    $self->{container} ||=
      Tu::AssetsContainer->new(public_dir => $home->catfile('public'));

    return $self->{container};
}

1;
