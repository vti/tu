use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::Builder;
use Tu::Plugin::CommonMiddleware;

subtest 'adds middleware in correct order' => sub {
    my $plugin = _build_plugin();

    $plugin->startup;

    is_deeply $plugin->builder->list_middleware, [
        qw/
          ErrorDocument
          HTTPExceptions
          Defaults
          Static
          RequestDispatcher
          ActionDispatcher
          ViewDisplayer
          /
    ];
};

done_testing;

sub _build_builder { Tu::Builder->new }

sub _build_plugin {
    my (%params) = @_;

    $params{builder} ||= _build_builder();

    Tu::Plugin::CommonMiddleware->new(%params);
}
