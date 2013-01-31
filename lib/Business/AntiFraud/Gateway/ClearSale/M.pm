package Business::AntiFraud::Gateway::ClearSale::M;
use Moo;
use Carp 'croak';
use bareword::filehandles;
use indirect;
use multidimensional;
use HTTP::Tiny;
use Data::Dumper;
extends qw/Business::AntiFraud::Gateway::Base/;

our    $VERSION     = '0.01';

=head2 ua

Uses HTTP::Tiny as useragent

=cut

has ua => (
    is => 'rw',
    default => sub { HTTP::Tiny->new() },
);

=head2 sandbox

Indica se homologação ou sandbox

=cut

has sandbox => ( is => 'rw' );

=head2 url_alterar_status

Holds the url_alterar_status. You DONT need to pass it, it will figure out its own url based on $self->sandbox

=cut

has url_alterar_status => (
    is => 'rw',
);

=head2 url_envio_pedido

Holds the url_alterar_status. You DONT need to pass it, it will figure out its own url based on $self->sandbox

=cut

has url_envio_pedido => (
    is => 'rw',
);

=head1 METHODS

=head2 BUILD

=cut

sub BUILD {
    my $self = shift;
    my $options = shift;

    $self->define_ambiente();

#   if ( exists $options->{ gateway } ) {
#       warn $options->{ gateway };
#       warn $options->{ gateway };
#       warn $options->{ gateway };
#   }
};

sub define_ambiente {
    my ( $self ) = @_;
    if ( $self->sandbox ) {
        $self->homologacao();
        return;
    }
    $self->producao();
}

sub homologacao {
    my ( $self ) = @_;
    $self->url_alterar_status('http://homologacao.clearsale.com.br/integracaov2/FreeClearSale/AlterarStatus.aspx');
    $self->url_envio_pedido('http://homologacao.clearsale.com.br/integracaov2/freeclearsale/frame.aspx');
}

sub producao {
    my ( $self ) = @_;
    $self->url_alterar_status('http://clearsale.com.br/integracaov2/FreeClearSale/AlterarStatus.aspx');
    $self->url_envio_pedido('http://www.clearsale.com.br/integracaov2/freeclearsale/frame.aspx');
}

=head2 create_xml

=cut

sub create_xml {
    my ( $self ) = @_;
    warn "\n\n*** GERAR FORMULARIO PARA POSTAR ***\n\n";

}

sub get_hidden_inputs {
    my ( $self, $info ) = @_;

    my $buyer       = $info->{buyer};
    my $cart        = $info->{cart};
    my $shipping    = $info->{shipping};

    my @hidden_inputs = (
        receiver_email => $self->receiver_email,
        currency       => $self->currency,
        encoding       => $self->form_encoding,
        payment_id     => $info->{payment_id},
        buyer_name     => $buyer->name,
        buyer_email    => $buyer->email,
    );

    #SHIPPING: {
    warn "x";

    my %buyer_extra = (
        address_line1    => 'shipping_address',
        address_line2    => 'shipping_address2',
        address_city     => 'shipping_city',
        address_state    => 'shipping_state',
        address_country  => 'shipping_country',
        address_zip_code => 'shipping_zip',
    );

    for (keys %buyer_extra) {
        if (my $value = $buyer->$_) {
            push @hidden_inputs, ( $buyer_extra{$_} => $value );
        }
    }

    my %cart_extra = (
        discount => 'discount_amount',
        handling => 'handling_amount',
        tax      => 'tax_amount',
    );

    for (keys %cart_extra) {
        if (my $value = $cart->$_) {
            push @hidden_inputs, ( $cart_extra{$_} => $value );
        }
    }

    my $i = 1;

    foreach my $item (@{ $info->{items} }) {
        push @hidden_inputs,
          (
               "Item_ID_${i}" => $item->id,
            "Item_Valor_${i}" => $item->price,
             "Item_Nome_${i}" => $item->name,
              "Item_Qtd_${i}" => $item->quantity,
          );

        if (my $category = $item->category) {
            push @hidden_inputs, ( "Item_Categoria_${i}" => $item->category);
        }

        $i++;
    }

    return @hidden_inputs;
}

=head1 NAME

Business::AntiFraud::Gateway::ClearSale::M - Interface perl para M-ClearSale

=head1 SYNOPSIS

  use Business::AntiFraud::Gateway::ClearSale::M;
  blah blah blah


=head1 DESCRIPTION

Stub documentation for this module was created by ExtUtils::ModuleMaker.
It looks like the author of the extension was negligent enough
to leave the stub unedited.

Blah blah blah.


=head1 USAGE



=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    Hernan Lopes
    CPAN ID: HERNAN
    -
    hernanlopes@gmail.com
    http://github.com/hernan604

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

1;
