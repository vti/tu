use strict;
use warnings;
use utf8;

use Test::More;
use Test::MonkeyMock;
use Test::Fatal;

use Encode ();
use Tu::Middleware::ViewDisplayer;

subtest 'throws when no displayer' => sub {
    my $services = Test::MonkeyMock->new;
    $services->mock(service => sub { });

    like
      exception { _build_middleware(displayer => undef, services => $services) }
    , qr/displayer required/;
};

subtest 'gets displayer from services' => sub {
    my $displayer = _mock_displayer();
    my $services  = Test::MonkeyMock->new;
    $services->mock(service => sub { $displayer });

    ok !
      exception { _build_middleware(displayer => undef, services => $services) };
};

subtest 'renders template' => sub {
    my $mw = _build_middleware(content => 'there');

    my $env = _build_env(
        'tu.displayer.template' => 'template.caml',
        'tu.displayer.vars'     => {hello => 'there'}
    );

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        ['Content-Length' => 5, 'Content-Type' => 'text/html; charset=utf-8'],
        ['there']
      ];
};

subtest 'render template with utf8' => sub {
    my $mw = _build_middleware(content => 'привет');

    my $env = _build_env('tu.displayer.template' => 'template-utf8.caml',);

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        [
            'Content-Length' => 12,
            'Content-Type'   => 'text/html; charset=utf-8'
        ],
        [Encode::encode_utf8('привет')]
      ];
};

subtest 'does no encode when encoding undefined' => sub {
    my $mw = _build_middleware(encoding => undef, content => 'привет');

    my $env = _build_env('tu.displayer.template' => 'template-utf8.caml',);

    my $res = $mw->call($env);

    is_deeply $res,
      [
        200,
        [
            'Content-Length' => 6,
            'Content-Type'   => 'text/html'
        ],
        ['привет']
      ];
};

subtest 'calls displayer with correct params' => sub {
    my $displayer = _mock_displayer();
    my $mw = _build_middleware(displayer => $displayer);

    my $env = _build_env(
        'tu.displayer.template' => 'custom_template',
        'tu.displayer.layout'   => 'custom_layout',
        'tu.displayer.vars'     => {foo => 'bar'}
    );

    $mw->call($env);

    my ($template, %args) = $displayer->mocked_call_args('render');

    is $template, 'custom_template';
    is_deeply \%args,
      {
        layout => 'custom_layout',
        vars   => {foo => 'bar'}
      };
};

subtest 'gets template name from dispatched request' => sub {
    my $dr = Test::MonkeyMock->new;
    $dr->mock(action => sub { 'from_action' });

    my $displayer = _mock_displayer();
    my $mw = _build_middleware(displayer => $displayer);

    my $env = _build_env('tu.dispatched_request' => $dr,);

    $mw->call($env);

    my ($template) = $displayer->mocked_call_args('render');

    is $template, 'from_action';
};

subtest 'does nothing when dispatched_request has no action' => sub {
    my $dr = Test::MonkeyMock->new;
    $dr->mock(action => sub { '' });

    my $mw = _build_middleware();

    my $env = _build_env('tu.dispatched_request' => $dr,);

    my $res = $mw->call($env);

    is_deeply $res, [200, [], ['OK']];
};

sub _build_env {
    my (%params) = @_;

    return {'tu.displayer.vars' => {}, %params};
}

sub _mock_displayer {
    my (%params) = @_;

    my $displayer = Test::MonkeyMock->new;
    $displayer->mock(render => sub { $params{content} });
}

sub _build_middleware {
    my (%params) = @_;

    my $displayer = $params{displayer} || _mock_displayer(%params);

    return Tu::Middleware::ViewDisplayer->new(
        app => sub { [200, [], ['OK']] },
        displayer => $displayer,
        @_
    );
}

done_testing;
