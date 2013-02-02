package Business::AntiFraud::Gateway::ClearSale::M;
use Moo;
use Carp 'croak';
use bareword::filehandles;
use indirect;
use multidimensional;
use HTTP::Tiny;
use Data::Dumper;
use HTTP::Request::Common;
extends qw/Business::AntiFraud::Gateway::Base/;

our    $VERSION     = '0.01';

=head2 codigo_integracao
Seu codigo de integracao
=cut

has codigo_integracao => ( is => 'rw', required => 1, );

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
    my $self    = shift;
    my $options = shift;
    $self->define_ambiente();
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

=head2 envar_pedidos
recebe:
$form (HTML::Element)

e envia esse form->asHTML e retorna a resposta
=cut

sub enviar_pedidos {
    my ( $self, $form ) = @_;
    use Data::Printer;
    my $content = [];
    foreach my $item ( @{ $form->content_array_ref } ) {
        if (
            my $field_name  = $item->{name} and
            my $field_value = $item->{value} )
        {
            push @$content, $field_name => $field_value;
        }
    };
    my $res = $self->ua->request(
        'POST',
        $self->url_envio_pedido,
        {
            headers => {
                'Content-Type' => 'application/x-www-form-urlencoded',
            },
            content => POST($self->url_envio_pedido, [], Content => $content)->content,
        }
    );
    warn p $res;
}

sub push_to_hidden_inputs {
    my ( $self, $args ) = @_;
    next unless ref $args eq ref {};
    my $hidden_input_obj= $args->{ hidden_inputs };
    if (
        exists $args->{ fields_map } and
        exists $args->{ use_object }
        ) {
        my $keys_values_map = $args->{ fields_map };
        my $obj             = $args->{ use_object };
        foreach my $k ( keys $keys_values_map ) {
            my $attr_value = $keys_values_map->{$k}->{get_value_from};
            if ( my $val = $obj->$attr_value ) {
                push @{ $hidden_input_obj }, ($k => $val );
            }
        }
    } elsif (
        exists $args->{ items }
        ) {
        my $i = 1;
        foreach my $item ( @{ $args->{items} } ) {
            push @{ $hidden_input_obj },
              (
                   "Item_ID_${i}" => $item->id,
                "Item_Valor_${i}" => $item->price,
                 "Item_Nome_${i}" => $item->name,
                  "Item_Qtd_${i}" => $item->quantity,
              );

            if (my $category = $item->category) {
                push @{ $hidden_input_obj }, ( "Item_Categoria_${i}" => $item->category);
            }
            $i++;
        }
    }
    return $hidden_input_obj;
}

sub get_hidden_inputs {
    my ( $self, $info ) = @_;

    my $buyer       = $info->{buyer};
    my $cart        = $info->{cart};
    my $shipping    = $info->{shipping};
    my $billing     = $info->{billing};

    my @hidden_inputs = ( CodigoIntegracao => $self->codigo_integracao );

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->shipping_keys(),
        use_object    => $shipping
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->billing_keys(),
        use_object    => $billing
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->cart_keys(),
        use_object    => $cart
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->buyer_keys(),
        use_object    => $buyer
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        items         => $info->{items}
    } ) };

    return @hidden_inputs;
}

sub buyer_keys {
    my ( $self ) = @_;
    return {
        IP   => {
            get_value_from  => 'ip', #Which attrib should i get value from?
        },
    };
}

sub cart_keys {
    my ( $self ) = @_;
    return {
        TipoPagamento => {
            get_value_from => 'tipo_de_pagamento',
        },
        TipoCartao => {
            get_value_from => 'tipo_cartao',
        },
        Total => {
            get_value_from => 'total',
        },
        Parcelas => {
            get_value_from => 'parcelas',
        },
        Data => {
            get_value_from => 'data',
        },
        PedidoID => {
            get_value_from => 'pedido_id',
        },

    };
}


sub billing_keys {
    my ( $self ) = @_;
    return {
        Cobranca_Nome                => {
            get_value_from  => 'name',
        },
        Cobranca_Email => {
            get_value_from  => 'email',
        },
        Cobranca_Documento => {
            get_value_from  => 'document_id',
        },
        Cobranca_Logradouro => {
            get_value_from  => 'address_street',
        },
         Cobranca_Logradouro_Numero=> {
            get_value_from  => 'address_number',
        },
        Cobranca_Bairro => {
            get_value_from  => 'address_district',
        },
        Cobranca_Cidade=> {
            get_value_from  => 'address_city',
        },
        Cobranca_Estado => {
            get_value_from  => 'address_state',
        },
        Cobranca_CEP => {
            get_value_from  => 'address_zip_code',
        },
        Cobranca_Pais => {
            get_value_from  => 'address_country',
        },
        Cobranca_Logradouro_Complemento => {
            get_value_from  => 'address_complement',
        },
        Cobranca_Telefone => {
            get_value_from  => 'phone',
        },
        Cobranca_DDD_Telefone => {
            get_value_from  => 'phone_prefix',
        },
        Cobranca_Celular => {
            get_value_from  => 'celular',
        },
        Cobranca_DDD_Celular => {
            get_value_from  => 'celular_prefix',
        },
    };
}

sub shipping_keys {
    my ( $self ) = @_;
    return {
        Entrega_Nome => {
            get_value_from  => 'name',
        },
        Entrega_Email => {
            get_value_from  => 'email',
        },
        Entrega_Documento => {
            get_value_from  => 'document_id',
        },
        Entrega_Logradouro => {
            get_value_from  => 'address_street',
        },
        Entrega_Logradouro_Numero => {
            get_value_from  => 'address_number',
        },
        Entrega_Bairro => {
            get_value_from  => 'address_district',
        },
        Entrega_Cidade => {
            get_value_from  => 'address_city',
        },
        Entrega_Estado => {
            get_value_from  => 'address_state',
        },
        Entrega_CEP => {
            get_value_from  => 'address_zip_code',
        },
        Entrega_Pais => {
            get_value_from  => 'address_country',
        },
        Entrega_Logradouro_Complemento => {
            get_value_from  => 'address_complement',
        },
        Entrega_Telefone => {
            get_value_from  => 'phone',
        },
        Entrega_DDD_Telefone => {
            get_value_from  => 'phone_prefix',
        },
        Entrega_Celular => {
            get_value_from  => 'celular',
        },
        Entrega_DDD_Celular => {
            get_value_from  => 'celular_prefix',
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
