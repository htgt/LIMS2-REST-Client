package LIMS2::REST::Client::Error;

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use Scalar::Util qw( blessed );
use HTTP::Status qw( :constants );
use Data::Dump   qw( pp );
use JSON         qw( decode_json );
use Try::Tiny;

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
};

use overload '""' => \&as_string;

sub as_string {
    my $self = shift;

    my $str = $self->message . "\n";

    my $content = $self->response->content;
    if ( $content ) {
        try {
            my $data = decode_json( $content );
            $str .= pp $data;
        }
        catch {
            $str .= $content;
        }
    }

    return $str;
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
    return shift->is_status( HTTP_BAD_REQUEST );
}

__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
