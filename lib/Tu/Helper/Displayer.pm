package Tu::Helper::Displayer;

use strict;
use warnings;

use base 'Tu::Helper';

sub render {
    my $self = shift;
    my ($template, @vars) = @_;

    my $vars = {%{$self->scope->displayer->vars}, @vars};

    return $self->service('displayer')
      ->render($template, layout => undef, vars => $vars);
}

1;

