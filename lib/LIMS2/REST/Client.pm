package LIMS2::REST::Client;
# ABSTRACT: LIMS2 REST Client

use strict;
use warnings FATAL => 'all';

use Moose;
use MooseX::Types::URI qw( Uri );
use LWP::UserAgent;
use HTTP::Request;
use JSON qw( to_json from_json );
use URI;
use LIMS2::REST::Client::Error;
use namespace::autoclean;

with qw( MooseX::SimpleConfig MooseX::Log::Log4perl );

has '+configfile' => (
    default => $ENV{LIMS2_REST_CLIENT_CONFIG}
);

has api_url => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1,
    required => 1
);

has username => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has password => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has realm => (
    is       => 'ro',
    isa      => 'Str',
    default  => 'LIMS2 API'
);

has proxy_url => (
    is       => 'ro',
    isa      => Uri,
    coerce   => 1
);

has ua => (
    is         => 'ro',
    isa        => 'LWP::UserAgent',
    lazy_build => 1
);

sub _build_ua {
    my $self = shift;

    # Set proxy
    my $ua = LWP::UserAgent->new( keep_alive => 1 );
    $ua->proxy( http => $self->proxy_url )
        if defined $self->proxy_url;

    # Set credentials
    if ( $self->username ) {
        $ua->credentials( $self->api_url->host_port, $self->realm, $self->username, $self->password );
    }

    return $ua;
}

=head2 uri_for( $path, @args?, \%query_params? )

=cut

sub uri_for {
    my $self = shift;

    my $uri = $self->api_url->clone;

    my @path_segments = $uri->path_segments;

    while ( @_ ) {
        last if ref $_[0];
        push @path_segments, shift @_;
    }

    $uri->path_segments( @path_segments );

    if ( @_ ) {
        $uri->query_form( shift @_ );
    }

    return $uri;
}

sub GET {
    my $self = shift;

    $self->_wrap_request( 'GET', $self->uri_for( @_ ), [ content_type => 'application/json' ] );
}

sub DELETE {
    my $self = shift;

    $self->_wrap_request( 'DELETE', $self->uri_for( @_ ), [ content_type => 'application/json' ] );
}

sub POST {
    my $self = shift;
    my $data = pop;

    $self->_wrap_request( 'POST', $self->uri_for( @_ ), [ content_type => 'application/json' ], to_json( $data ) );
}

sub PUT {
    my $self = shift;
    my $data = pop;

    $self->_wrap_request( 'PUT', $self->uri_for( @_ ), [ content_type => 'application/json' ], to_json( $data ) );
}

sub _wrap_request {
    my $self = shift;

    my $request = HTTP::Request->new( @_ );

    $self->log->debug( $request->method . ' request for ' . $request->uri );    
    if ( $request->content ) {
        $self->log->trace( sub { "Request data: " . $request->content } );
    }

    my $response = $self->ua->request($request);

    $self->log->debug( 'Response: ' . $response->status_line );

    if ( $response->is_success ) {
        return from_json( $response->content );
    }

    LIMS2::Client::Error->throw( $response );
}

__PACKAGE__->meta->make_immutable;

1;

__END__
