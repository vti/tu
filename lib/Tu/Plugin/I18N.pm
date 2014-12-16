package Tu::Plugin::I18N;

use strict;
use warnings;

use parent 'Tu::Plugin';

use Carp qw(croak);
use Tu::I18N;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{lexicon} = $params{lexicon} || 'perl';

    $self->{service_name}             = $params{service_name};
    $self->{helper_name}              = $params{helper_name};
    $self->{insert_before_middleware} = $params{insert_before_middleware};

    $self->{service_name}             ||= 'i18n';
    $self->{helper_name}              ||= $self->{service_name};
    $self->{helper_name}              ||= $self->{service_name};
    $self->{insert_before_middleware} ||= 'RequestDispatcher';

    return $self;
}

sub startup {
    my $self = shift;

    my $app_class = $self->service('app_class');
    my $home = $self->home;

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

    my $i18n = $self->_build_i18n(
        app_class  => $app_class,
        locale_dir => $locale_dir,
        lexicon    => $lexicon
    );
    $self->{services}->register($self->{service_name} => $i18n);

    $self->insert_before_middleware($self->{insert_before_middleware},
        'I18N', i18n => $i18n);
}

sub _build_i18n {
    my $self = shift;

    return Tu::I18N->new(@_);
}

1;
