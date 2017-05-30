use strict;
use warnings;

use Test::More;
use Test::Fatal;
use Test::TempDir::Tiny;

use Tu::AssetsContainer;

subtest 'requires js' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');

    is($assets->include,
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'requires js as is' => sub {
    my $assets = _build_assets();

    $assets->require(\'1 + 1', type => 'js');

    is($assets->include, '<script type="text/javascript">1 + 1</script>');
};

subtest 'requires with specified type' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.bar', type => 'js');

    is($assets->include,
        '<script src="/foo.bar" type="text/javascript"></script>');
};

subtest 'requires css' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.css');

    is($assets->include,
'<link rel="stylesheet" href="/foo.css" type="text/css" media="screen" />'
    );
};

subtest 'does not add same requires' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');
    $assets->require('/foo.js');

    is($assets->include,
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'includes only specified type' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js');
    $assets->require('/foo.css');

    is($assets->include(type => 'js'),
        '<script src="/foo.js" type="text/javascript"></script>');
};

subtest 'orders by index' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js', index => 10);
    $assets->require('/last.js');
    $assets->require('/bar.js', index => 5);

    is(
        $assets->include(type => 'js'),
        '<script src="/bar.js" type="text/javascript"></script>' . "\n"
          . '<script src="/foo.js" type="text/javascript"></script>' . "\n"
          . '<script src="/last.js" type="text/javascript"></script>'
    );
};

subtest 'adds custom attributes' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.js', attrs => {foo => 'bar'});

    is($assets->include(type => 'js'),
        '<script src="/foo.js" type="text/javascript" foo="bar"></script>');
};

subtest 'throws when unknown type' => sub {
    my $assets = _build_assets();

    $assets->require('/foo.foo');

    like exception { $assets->include }, qr/unknown asset type 'foo'/;
};

subtest 'add version if public_dir present' => sub {
    my $public_dir = tempdir();

    my ($mtime) = (stat _write_file("$public_dir/foo.js", '1 + 1'))[9];

    my $assets = _build_assets(public_dir => $public_dir);

    $assets->require('/foo.js');

    is $assets->include(type => 'js'),
      qq{<script src="/foo.js?v=$mtime" type="text/javascript"></script>};
};

subtest 'not add version if public_dir present but no file' => sub {
    my $public_dir = tempdir();

    my $assets = _build_assets(public_dir => $public_dir);

    $assets->require('/foo.js');

    is $assets->include(type => 'js'),
      qq{<script src="/foo.js" type="text/javascript"></script>};
};

sub _write_file {
    my ($file, $content) = @_;

    open my $fh, '>', $file or die $!;
    print $fh $content;
    close $fh;

    return $file;
}

sub _build_assets {
    return Tu::AssetsContainer->new(@_);
}

done_testing;
