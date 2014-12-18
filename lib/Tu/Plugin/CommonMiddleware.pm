package Tu::Plugin::CommonMiddleware;

use strict;
use warnings;

use parent 'Tu::Plugin';

sub startup {
    my $self = shift;

    $self->add_middleware(
        'ErrorDocument',
        403        => '/forbidden',
        404        => '/not_found',
        subrequest => 1
    );

    $self->add_middleware('HTTPExceptions');

    $self->add_middleware('Defaults');

    $self->add_middleware('Static');

    $self->add_middleware('RequestDispatcher');
    $self->add_middleware('ActionDispatcher');
    $self->add_middleware('ViewDisplayer');
}

1;
