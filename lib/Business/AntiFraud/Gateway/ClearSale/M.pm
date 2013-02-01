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

use Data::Printer;
warn p $info;
    my $buyer       = $info->{buyer};
    my $cart        = $info->{cart};
    my $shipping    = $info->{shipping};
    my $billing     = $info->{billing};

    my @hidden_inputs = (
        receiver_email => $self->receiver_email,
        currency       => $self->currency,
        encoding       => $self->form_encoding,
        payment_id     => $info->{payment_id},
        buyer_name     => $buyer->name,
        buyer_email    => $buyer->email,
    );

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

    my $shipping_keys = $self->shipping_keys();
    foreach my $k ( keys $shipping_keys ) {
        my $coerce_to = $shipping_keys->{$k}->{value_from};
        if ( my $val = $shipping->$coerce_to ) {
            push @hidden_inputs, (
                $shipping_keys->{$k}->{rename_field_to} => $val );
        }
    }


    my $billing_keys = $self->billing_keys();
    foreach my $k ( keys $billing_keys ) {
        my $coerce_to = $billing_keys->{$k}->{value_from};
        if ( my $val = $billing->$coerce_to ) {
            push @hidden_inputs, (
                $billing_keys->{$k}->{rename_field_to} => $val );
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

sub billing_keys {
    my ( $self ) = @_;
    return {
        name                => {
            rename_field_to => 'Cobranca_Nome',
            value_from      => 'name',
        },
        email => {
            rename_field_to => 'Cobranca_Email',
            value_from      => 'email',
        },
        document_id => {
            rename_field_to => 'Cobranca_Documento',
            value_from      => 'document_id',
        },
        address_street => {
            rename_field_to => 'Cobranca_Logradouro',
            value_from      => 'address_street',
        },
        address_number => {
            rename_field_to => 'Cobranca_Logradouro_Numero',
            value_from      => 'address_number',
        },
        address_district => {
            rename_field_to => 'Cobranca_Bairro',
            value_from      => 'address_district',
        },
        address_city => {
            rename_field_to => 'Cobranca_Cidade',
            value_from      => 'address_city',
        },
        address_state => {
            rename_field_to => 'Cobranca_Estado',
            value_from      => 'address_state',
        },
        address_zip_code => {
            rename_field_to => 'Cobranca_CEP',
            value_from      => 'address_zip_code',
        },
        address_country => {
            rename_field_to => 'Cobranca_Pais',
            value_from      => 'address_country',
        },
        phone => {
            rename_field_to => 'Cobranca_Telefone',
            value_from      => 'phone',
        },
        phone_prefix => {
            rename_field_to => 'Cobranca_DDD_Telefone',
            value_from      => 'phone_prefix',
        },
        celular => {
            rename_field_to => 'Cobranca_Celular',
            value_from      => 'celular',
        },
        celular_prefix => {
            rename_field_to => 'Cobranca_DDD_Celular',
            value_from      => 'celular_prefix',
        },
    };
}

sub shipping_keys {
    my ( $self ) = @_;
    return {
        name                => {
            rename_field_to => 'Entrega_Nome',
            value_from      => 'name',
        },
        email => {
            rename_field_to => 'Entrega_Email',
            value_from      => 'email',
        },
        document_id => {
            rename_field_to => 'Entrega_Documento',
            value_from      => 'document_id',
        },
        address_street => {
            rename_field_to => 'Entrega_Logradouro',
            value_from      => 'address_street',
        },
        address_number => {
            rename_field_to => 'Entrega_Logradouro_Numero',
            value_from      => 'address_number',
        },
        address_district => {
            rename_field_to => 'Entrega_Bairro',
            value_from      => 'address_district',
        },
        address_city => {
            rename_field_to => 'Entrega_Cidade',
            value_from      => 'address_city',
        },
        address_state => {
            rename_field_to => 'Entrega_Estado',
            value_from      => 'address_state',
        },
        address_zip_code => {
            rename_field_to => 'Entrega_CEP',
            value_from      => 'address_zip_code',
        },
        address_country => {
            rename_field_to => 'Entrega_Pais',
            value_from      => 'address_country',
        },
        phone => {
            rename_field_to => 'Entrega_Telefone',
            value_from      => 'phone',
        },
        phone_prefix => {
            rename_field_to => 'Entrega_DDD_Telefone',
            value_from      => 'phone_prefix',
        },
        celular => {
            rename_field_to => 'Entrega_Celular',
            value_from      => 'celular',
        },
        celular_prefix => {
            rename_field_to => 'Entrega_DDD_Celular',
            value_from      => 'celular_prefix',
        },
    };
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
