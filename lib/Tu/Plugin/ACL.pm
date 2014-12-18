package Tu::Plugin::ACL;

use strict;
use warnings;

use parent 'Tu::Plugin';

use Carp qw(croak);
use Tu::ACL::FromConfig;

sub new {
    my $self = shift->SUPER::new(@_);
    my (%params) = @_;

    $self->{user_loader} = $params{user_loader}
      || croak('$user_loader required');
    $self->{acl} = $params{acl};

    return $self;
}

sub startup {
    my $self = shift;

    $self->insert_before_middleware('RequestDispatcher',
        'Session::Cookie', services => $self->services);

    $self->insert_before_middleware(
        'RequestDispatcher', 'User',
        services    => $self->services,
        user_loader => $self->{user_loader}
    );

    $self->services->register(acl => 'Tu::ACL', new => 1);

    $self->insert_before_middleware(
        'ActionDispatcher', 'ACL',
        services => $self->services,
        acl      => $self->{acl}
    );
}

1;
