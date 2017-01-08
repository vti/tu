requires 'JSON';
requires 'Plack';
requires 'Routes::Tiny' => '0.14';
requires 'String::CamelCase';

recommends 'Email::MIME';
recommends 'JSON';
recommends 'Text::Caml';
recommends 'Text::APL';
recommends 'YAML::Tiny';
recommends 'Plack::Middleware::Session';
recommends 'Plack::Middleware::Session::Cookie';
recommends 'I18N::AcceptLanguage';

on 'test' => sub {
    requires 'Test::Requires';
    requires 'Test::Fatal';
    requires 'Test::More';
    requires 'Test::MonkeyMock';
    requires 'Test::TempDir::Tiny';
};
