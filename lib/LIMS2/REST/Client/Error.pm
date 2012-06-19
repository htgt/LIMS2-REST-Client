package LIMS2::Client::Error;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use Scaler::Util qw( blessed );
use HTTP::Status qw( :constants );

with 'Throwable';

has response => (
    is      => 'ro',
    isa     => 'HTTP::Response',
    handles => [ qw( message ) ]        
);

around BUILDARGS => sub {
    my ( $orig, $class, @args ) = @_;

    if ( @args == 1 and blessed $args[0] eq 'HTTP::Response' ) {
        return $class->$orig( { response => $args[0] } );
    }

    return $class->$orig( @args );
}

overload '""' => \&as_string;

sub as_string {
    my $self = shift;
    return $self->message;
}

# XXX Do we need these? Do we need others?

sub is_status {
    my ( $self, $status ) = @_;

    return $self->response->code == $status;
}

sub not_found {
    return shift->is_status( HTTP_NOT_FOUND );
}

sub conflict {
    return shift->is_status( HTTP_CONFLICT );
}

sub bad_request {
    return shift->is_status( BAD_REQUEST );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
