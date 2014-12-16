package Tu::Plugin::ObjectDB;

use strict;
use warnings;

use parent 'Tu::Plugin';

use Tu::Loader;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{config_key} = $params{config_key} || 'database';
    $self->{db_class} = $params{db_class};

    return $self;
}

sub startup {
    my $self = shift;

    my $db_class = $self->{db_class} || $self->{services}->service('app_class') . '::DB';

    Tu::Loader->new->load_class($db_class);

    my $config = $self->{services}->service('config');
    $db_class->init_db(%{$config->{$self->{config_key}} || {}});

    return $self;
}

1;
