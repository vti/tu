use strict;
use warnings;

use Test::More;
use Test::Fatal;

use Tu;

subtest 'returns coderef' => sub {
    my $app = TestApp->new;

    is ref $app->to_app, 'CODE';
};

subtest 'defaults to 404' => sub {
    my $app = Tu->new;

    like exception { $app->to_app->() }, qr/Not Found/;
};

subtest 'registers services' => sub {
    my $app = TestApp->new(home => '/foo/bar');

    my $home = $app->service('home');
    is $home, '/foo/bar';

    my $app_class = $app->service('app_class');
    is $app_class, 'TestApp';
};

done_testing;

package TestApp;
use parent 'Tu';

sub startup { }
