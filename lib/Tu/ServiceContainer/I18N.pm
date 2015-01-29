package Tu::ServiceContainer::I18N;

use strict;
use warnings;

use Carp qw(croak);
use Tu::I18N;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub register {
    my $self = shift;
    my ($services, %params) = @_;

    $self->{lexicon}    = $params{lexicon}    || 'perl';
    $self->{config_key} = $params{config_key} || 'i18n';

    $self->{service_name} = $params{service_name} || 'i18n';

    my $app_class = $services->service('app_class');
    my $home      = $services->service('home');

    $app_class =~ s{::}{/}g;

    my $path = $INC{"$app_class.pm"};
    $path =~ s{\.pm$}{/I18N} if $path;

    my $locale_dir;
    my $lexicon;
    if ($path && -d $path) {
        $locale_dir = $path;
        $lexicon    = 'perl';
    }
    elsif (-d $home->catfile('locale')) {
        $locale_dir = $home->catfile('locale');
        $lexicon    = 'gettext';
    }
    else {
        croak 'Cannot detect locale_dir';
    }

    my $config =
         $params{config}
      || $services->service('config')->{$self->{config_key}}
      || {};
    croak 'i18n not configured' unless %$config;

    my $i18n = $self->_build_i18n(
        default_language => $config->{default_language},
        languages        => $config->{languages},
        app_class        => $app_class,
        locale_dir       => $locale_dir,
        lexicon          => $lexicon
    );

    $services->register($self->{service_name} => $i18n);

    return $self;
}

sub _build_i18n {
    my $self = shift;

    return Tu::I18N->new(@_);
}

1;
