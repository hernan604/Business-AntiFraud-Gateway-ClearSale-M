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

=head1 ATTRIBUTES

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
Holds the url_alterar_status. You DONT need to pass it,
it will figure out its own url based on $self->sandbox
=cut

has url_alterar_status => (
    is => 'rw',
);

=head2 url_envio_pedido
Holds the url_alterar_status. You DONT need to pass it,
it will figure out its own url based on $self->sandbox
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

=head2 envar_pedidos
recebe:
$form (HTML::Element)

e envia esse form->asHTML e retorna a resposta em html

    "<html>

        ...

        <h3>Status:</h3>
        <div class="AMA" title="Status: AMA – Analise Manual">
            <span>AMA</span>
        </div>

        ...

    </html>",
        headers    {
            cache-control      "private",
            connection         "close",
            content-length     8323,
            content-type       "text/html; charset=utf-8",
            date               "Tue, 05 Feb 2013 11:23:36 GMT",
            server             "Microsoft-IIS/6.0",
            x-aspnet-version   "2.0.50727",
            x-powered-by       "ASP.NET"
        },
        protocol   "HTTP/1.1",
        reason     "OK",
        status     200,
        success    1,
        url        "http://homologacao.clearsale.com.br/integracaov2/freeclearsale/frame.aspx"
    }
=cut

sub enviar_pedido {
    my ( $self, $form ) = @_;
    my $content = [map{ $_->{name} => $_->{value} } @{ $form->content_array_ref }];
    return $self->ua->request(
        'POST',
        $self->url_envio_pedido,
        {
            headers => {
                'Content-Type' => 'application/x-www-form-urlencoded',
            },
            content => POST($self->url_envio_pedido, [], Content => $content)->content,
        }
    );
}

=head2 enviar_pedido_iframe_markup
Retorna um markup HTML para inserir a imagem de decisão em sua página HTML ex:

    <iframe src="http://homologacao.clearsale.com.br/integracaov2/FreeClearSale/frame.aspx?
        CodigoInt egracao=00000000-0000-0000-0000-000000000000&PedidoID=12345&Data=..."
        width="280" height="85" frameborder="0" scrolling="no">
        <P>Seu Browser não suporta iframes</P>
    </iframe>

=cut

sub enviar_pedido_iframe_markup {
    my ( $self, $form ) = @_;
    my $content = [map{ $_->{name} => $_->{value} } @{ $form->content_array_ref }];
    my $query_str = POST($self->url_envio_pedido, [], Content => $content)->content;
    my $html_markup = q{
        <iframe src="}.
        $self->url_envio_pedido .'?'. $query_str
        .q{" width="280" height="85" frameborder="0" scrolling="no"><P>Seu Browser não suporta iframes</P></iframe>
    };
    return $html_markup;
}

=head2 atualizar_status( $pedido_id, $status )
Recebe:
$pedido_id: o id do pedido registrado no clearsale
$status: pode ser um destes:
CAN - Cancelado pelo cliente
SUS - Suspeito
APM - Aprovado
FRD - Fraude Confirmada
RPM - Reprovado

    my $res = $antifraud->atualizar_status( $pedido_id, $status );
    use Data::Printer; warn p $res;

    \ {
        content    "0|OK",
        headers    {
            cache-control      "private",
            connection         "close",
            content-length     4,
            content-type       "text/html; charset=utf-8",
            date               "Tue, 05 Feb 2013 11:23:37 GMT",
            server             "Microsoft-IIS/6.0",
            x-aspnet-version   "2.0.50727",
            x-powered-by       "ASP.NET"
        },
        protocol   "HTTP/1.1",
        reason     "OK",
        status     200,
        success    1,
        url        "http://homologacao.clearsale.com.br/integracaov2/FreeClearSale/AlterarStatus.aspx"
    }

=cut

sub atualizar_status {
    my ( $self, $pedido_id, $status ) = @_;
    my $content = [
        PedidoID            => $pedido_id,
        Status              => $status,
        CodigoIntegracao    => $self->codigo_integracao,
    ];
    return $self->ua->request(
        'POST',
        $self->url_alterar_status,
        {
            headers => {
                'Content-Type' => 'application/x-www-form-urlencoded',
            },
            content => POST($self->url_envio_pedido, [], Content => $content)->content,
        }
    );
}

#insere mais itens para o formulario
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
        fields_map    => $self->shipping_fields(),
        use_object    => $shipping
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->billing_fields(),
        use_object    => $billing
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->cart_fields(),
        use_object    => $cart
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        fields_map    => $self->buyer_fields(),
        use_object    => $buyer
    } ) };

    @hidden_inputs = @{ $self->push_to_hidden_inputs( {
        hidden_inputs => \@hidden_inputs ,
        items         => $info->{items}
    } ) };

    return @hidden_inputs;
}

sub buyer_fields {
    my ( $self ) = @_;
    return {
        IP   => {
            get_value_from  => 'ip', #Which attrib should i get value from?
        },
    };
}

sub cart_fields {
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


sub billing_fields {
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

sub shipping_fields {
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
