use strict;
use warnings;

use Test::More;

use Tu::Plugins;

use lib 't/plugins_t';

subtest 'run_plugins' => sub {
    my $plugins = _build_plugins();

    $plugins->register_plugin('Plugin');

    my $env = {};
    $plugins->run_plugins($env);

    is $env->{foo}, 'bar';
};

sub _build_plugins { Tu::Plugins->new(@_) }

done_testing;
