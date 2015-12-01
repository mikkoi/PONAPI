package PONAPI::DAO::Request::UpdateRelationships;

use Moose;

use PONAPI::DAO::Constants;

extends 'PONAPI::DAO::Request';

has data => (
    is        => 'ro',
    isa       => 'Maybe[HashRef|ArrayRef]',
    predicate => 'has_data',
);

sub BUILD {
    my $self = shift;

    $self->check_has_id;
    $self->check_has_rel_type;
    $self->check_has_data;
}

sub execute {
    my ( $self, $repo ) = @_;
    my $doc = $self->document;

    if ( $self->is_valid ) {
        eval {
            my ($ret, @extra) = $repo->update_relationships( %{ $self } );

            return unless $self->_verify_repository_response($ret, @extra);

            $doc->add_meta(
                message => "successfully updated the relationship /"
                         . $self->type
                         . "/"
                         . $self->id
                         . "/"
                         . $self->rel_type
                         . " => "
                         . $self->json->encode( $self->data )
            );
            1;
        } or do {
            # NOTE: this probably needs to be more sophisticated - SL
            warn "$@";
            $self->_server_failure;
        };
    }

    return $self->response();
}


__PACKAGE__->meta->make_immutable;
no Moose; 1;
