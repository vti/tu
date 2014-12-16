use strict;
use warnings;

use Test::More;
use Test::MonkeyMock;

use Tu::Home;
use Tu::Middleware::Static;

subtest 'discovers static files automatically' => sub {
    my $mw = _build_middleware();

    my $res = $mw->call(
        {
            REQUEST_METHOD => 'GET',
            SCRIPT_NAME    => '/',
            PATH_INFO      => '/static/file.txt'
        }
    );

    my $fh = $res->[2];
    is <$fh>, "hello\n";
};

sub _build_home {
    Tu::Home->new(path => 't/middleware/static_t');
}

sub _mock_services {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { _build_home() });
}

sub _build_middleware {
    my (%params) = @_;

    $params{services} ||= _mock_services();

    return Tu::Middleware::Static->new(
        app => sub { [200, [], ['OK']] },
        %params
    );
}

done_testing;
