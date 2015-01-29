use strict;
use warnings;

use Test::More;
use Plack::Test;

use lib 't/app/simple_t/lib';

use HTTP::Request;

my $app =
  eval do { local $/; open my $fh, '<', 't/app/simple_t/app.psgi'; <$fh> };

subtest 'simple app' => sub {
    test_psgi
      app    => $app,
      client => sub {
        my $cb  = shift;
        my $req = HTTP::Request->new(GET => '/');
        my $res = $cb->($req);

        like $res->content, qr/Hello world, bar!/;
      };
};

done_testing;
