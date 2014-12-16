use strict;
use warnings;

use Test::More;
use Plack::Test;

use lib 't/app/simple_t/lib';

use HTTP::Request;
use TestAppSimple;

subtest 'sadfasdf' => sub {
    my $app = TestAppSimple->new;

    test_psgi
      app    => $app->to_app,
      client => sub {
        my $cb  = shift;
        my $req = HTTP::Request->new(GET => '/');
        my $res = $cb->($req);

        like $res->content, qr/Hello world, bar!/;
      };
};

done_testing;
