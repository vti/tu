package Tu::Middleware::Static;

use strict;
use warnings;

use base 'Plack::Middleware::Static';

sub new {
    my $class = shift;
    my (%params) = @_;

    if (!$params{path} && !$params{root}) {
        my $config = $params{services}->service('config');

        my $public_dir =
          $params{public_dir} || $config->{public_dir} || 'public';
        $public_dir = $params{services}->service('home')->catfile($public_dir);

        my @dirs = grep { -d } glob "$public_dir/*";
        s/^$public_dir\/?// for @dirs;

        my $re = '^/(?:' . join('|', @dirs) . ')/';
        $params{path} = qr/$re/;
        $params{root} = $public_dir;
    }

    return $class->SUPER::new(%params);
}

1;
