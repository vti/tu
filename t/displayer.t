use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::MonkeyMock;

use Tu::Displayer;

subtest 'throws when no renderer' => sub {
    like exception {
        Tu::Displayer->new
    }, qr/renderer required/;
};

subtest 'correctly renders string' => sub {
    my $r = _mock_renderer(content_string => 'hi there');
    my $d = _build_displayer(renderer => $r);

    is $d->render(\'template', vars => {foo => 'bar'}), 'hi there';

    my ($string, $vars) = $r->mocked_call_args('render_string');
    is $string, 'template';
    is_deeply $vars, {foo => 'bar'};
};

subtest 'correctly renders file' => sub {
    my $r = _mock_renderer(content_file => 'hi there');
    my $d = _build_displayer(renderer => $r);

    is $d->render('template', vars => {foo => 'bar'}), 'hi there';

    my ($file, $vars) = $r->mocked_call_args('render_file');
    is $file, 'template';
    is_deeply $vars, {foo => 'bar'};
};

subtest 'forces global layout' => sub {
    my $r = _mock_renderer(content_file => 'hi there');
    my $d = _build_displayer(renderer => $r, layout => 'custom_layout');

    $d->render('template', vars => {foo => 'bar'});

    my ($file, $vars) = $r->mocked_call_args('render_file');

    is $file, 'template';
    is_deeply $vars, {foo => 'bar'};

    ($file, $vars) = $r->mocked_call_args('render_file', 1);

    is $file, 'custom_layout';
    is_deeply $vars, {content => 'hi there', foo => 'bar'};
};

subtest 'skips global layout when local undef' => sub {
    my $r = _mock_renderer(content_file => 'hi there');
    my $d = _build_displayer(renderer => $r, layout => 'custom_layout');

    $d->render('template', vars => {foo => 'bar'}, layout => undef);

    is $r->mocked_called('render_file'), 1;
};

subtest 'uses local layout' => sub {
    my $r = _mock_renderer(content_file => 'hi there');
    my $d = _build_displayer(renderer => $r, layout => 'custom_layout');

    $d->render('template', vars => {foo => 'bar'}, layout => 'local_layout');

    my ($file, $vars) = $r->mocked_call_args('render_file', 1);

    is $file, 'local_layout';
    is_deeply $vars, {content => 'hi there', foo => 'bar'};
};

sub _mock_renderer {
    my (%params) = @_;

    my $renderer = Test::MonkeyMock->new;
    $renderer->mock(render_file => sub { $params{content_file} });
    $renderer->mock(render_string => sub { $params{content_string} });
}

sub _build_displayer {
    my (%params) = @_;

    my $renderer = $params{renderer} || _mock_renderer();

    Tu::Displayer->new(renderer => $renderer, @_);
}

done_testing;
