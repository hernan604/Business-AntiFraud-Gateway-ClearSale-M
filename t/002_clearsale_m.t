# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use warnings;
use strict;
use Test::More;

BEGIN { use_ok('Business::AntiFraud'); }

#my $object = Business::AntiFraud->new ();
#isa_ok ($object, 'Business::AntiFraud');
use Business::AntiFraud;
use DateTime;

my $antifraud = eval {
    Business::AntiFraud->new(
        codigo_integracao   => '4FDAE0FD-6937-4463-A2D2-84FFB48A71E0',
        sandbox             => 1,
        gateway             => 'ClearSale::M',
        receiver_email      => 'hernanlopes@gmail.com',
        currency            => 'BRL',
        checkout_url        => '',
    );
};

ok( $antifraud, 'the object was defined' );
ok( !$@,        'no error' );

if ($@) {
    diag $@;
}

isa_ok( $antifraud, 'Business::AntiFraud::Gateway::ClearSale::M' );

my $data = DateTime->new(
    year   => 2012,
    month  => 04,
    day    => 20,
    hour   => 04,
    minute => 20,
    second => 00,
);

my $cart = $antifraud->new_cart(
    {
        pedido_id => 'P3D1D0-1D-1NT3RN0-420',
        data      => $data,
        parcelas  => 2,
        tipo_de_pagamento =>
          1,    #2=boleto. mais em: Cart::ClearSale::M >> tipo_de_pagamento
        tipo_cartao => 2,
        total       => 12.90,
        buyer       => {

            #email => 'hernan@cpan.org',
            #name  => 'Mr. Buyer',
            ip => '200.232.107.100',
        },
        shipping => {
            name               => 'Nome Shipping',
            email              => 'email@shipping.com',
            document_id        => '999222111555',
            address_street     => 'Rua shipping',
            address_number     => '334',
            address_district   => 'Ships',
            address_city       => 'Shipping City',
            address_state      => 'Vila Shipping',
            address_zip_code   => '99900-099',
            address_country    => 'Espanha',
            address_complement => 'apto 40',
            phone              => '7770-0201',
            phone_prefix       => '13',
            celular            => '99900-0000',
            celular_prefix     => '14',
        },
        billing => {
            name               => 'Nome Billing',
            email              => 'email@billing.com',
            document_id        => '999222111222',
            address_street     => 'Rua billing',
            address_number     => '333',
            address_district   => 'Bills',
            address_city       => 'Bill City',
            address_state      => 'Vila Bill',
            address_zip_code   => '99900-022',
            address_country    => 'Brazil',
            address_complement => 'apto 50',
            phone              => '5670-0201',
            phone_prefix       => '11',
            celular            => '99900-9382',
            celular_prefix     => '15',
        },
    }
);
$cart->add_item(
    {
        id       => 1,
        name     => 'Produto NOME1',
        category => 'Informática',
        price    => 200.5,
        quantity => 10,
    }
);

$cart->add_item(
    {
        id       => '02',
        name     => 'Produto NOME2',
        price    => 0.56,
        quantity => 5,
    }
);

$cart->add_item(
    {
        id       => '03',
        name     => 'Produto NOME3',
        price    => 10,
        quantity => 1,
    }
);

$cart->add_item(
    {
        id       => 'my-id',
        name     => 'Produto NOME4',
        price    => 10,
        quantity => 1,
    }
);

{
    my $item = eval { $cart->get_item(1) };

    ok( $item, 'item is defined' );
    ok( !$@,   'no error' );

    if ($@) {
        diag $@;
    }

    isa_ok( $item           , 'Business::AntiFraud::Item' );
    is(     $item->id       , '1'       , 'item id is correct' );
    isnt(   $item->price    , 200.5     , 'item price is not numeric' );
    is(     $item->price    , '200.50'  , 'item price is correct' );
    is(     $item->quantity , 10        , 'item quantity is correct' );
}

{
    my $item = eval { $cart->get_item('02') };

    ok( $item, 'item is defined' );
    ok( !$@,   'no error' );

    if ($@) {
        diag $@;
    }

    isa_ok( $item, 'Business::AntiFraud::Item' );
    is( $item->id,       '02',   'item id is correct' );
    is( $item->price,    '0.56', 'item price is correct' );
    is( $item->quantity, 5,      'item quantity is correct' );
}

{
    my $item = eval { $cart->get_item('03') };

    ok( $item, 'item is defined' );
    ok( !$@,   'no error' );

    if ($@) {
        diag $@;
    }

    isa_ok( $item, 'Business::AntiFraud::Item' );

    is( $item->id, '03', 'item id is correct' );
    isnt( $item->price, 10, 'item price is not numeric' );
    is( $item->price,    '10.00', 'item price is correct' );
    is( $item->quantity, 1,       'item quantity is correct' );
}

{
    my $item = eval { $cart->get_item('my-id') };

    ok( $item, 'item is defined' );
    ok( !$@,   'no error' );

    if ($@) {
        diag $@;
    }

    isa_ok( $item, 'Business::AntiFraud::Item' );

    is( $item->id, 'my-id', 'item id is correct' );
    isnt( $item->price, 10, 'item price is not numeric' );
    is( $item->price,    '10.00', 'item price is correct' );
    is( $item->quantity, 1,       'item quantity is correct' );
}

{
    ok( my $form = $cart->get_form_to_pay('pay123'), 'get form' );
    isa_ok( $form, 'HTML::Element' );
    warn "\n" . $form->as_HTML;
    warn "^^^";

    is( get_value_for( $form, 'item_Valor_1' ),
        '200.50', 'form value item1_price is correct' );
    is( get_value_for( $form, 'item_Qtd_1' ),
        '10', 'form value item1_qty is correct' );
    is( get_value_for( $form, 'item_ID_1' ),
        '1', 'form value item1_id is correct' );

    is( get_value_for( $form, 'item_Valor_2' ),
        '0.56', 'form value item2_price is correct' );
    is( get_value_for( $form, 'item_Qtd_2' ),
        '5', 'form value item2_qty is correct' );
    is( get_value_for( $form, 'item_ID_2' ),
        '02', 'form value item2_id is correct' );

    is( get_value_for( $form, 'item_Valor_3' ),
        '10.00', 'form value item3_price is correct' );
    is( get_value_for( $form, 'item_Qtd_3' ),
        '1', 'form value item3_qty is correct' );
    is( get_value_for( $form, 'item_ID_3' ),
        '03', 'form value item3_id is correct' );

    is( get_value_for( $form, 'item_Valor_4' ),
        '10.00', 'form value item4_price is correct' );
    is( get_value_for( $form, 'item_Qtd_4' ),
        '1', 'form value item4_qty is correct' );
    is( get_value_for( $form, 'item_ID_4' ),
        'my-id', 'form value item4_id is correct' );

    is( get_value_for( $form, 'PedidoID' ), 'P3D1D0-1D-1NT3RN0-420', '' );
    is(
        get_value_for( $form, 'Data' ),
        '20-04-2012 04:20:00',
        'Its 420! hurry up!'
    );
    is( get_value_for( $form, 'IP' ), '200.232.107.100', '' );

    is( get_value_for( $form, 'TipoPagamento' ), '1', '' );
    is( get_value_for( $form, 'TipoCartao' ),    '2', '' );

    is( get_value_for( $form, 'Cobranca_CEP' ),       '99900-022',         '' );
    is( get_value_for( $form, 'Cobranca_Pais' ),      'Brazil',            '' );
    is( get_value_for( $form, 'Cobranca_Nome' ),      'Nome Billing',      '' );
    is( get_value_for( $form, 'Cobranca_Email' ),     'email@billing.com', '' );
    is( get_value_for( $form, 'Cobranca_Bairro' ),    'Bills',             '' );
    is( get_value_for( $form, 'Cobranca_Cidade' ),    'Bill City',         '' );
    is( get_value_for( $form, 'Cobranca_Estado' ),    'Vila Bill',         '' );
    is( get_value_for( $form, 'Cobranca_Telefone' ),  '5670-0201',         '' );
    is( get_value_for( $form, 'Cobranca_Documento' ), '999222111222',      '' );
    is( get_value_for( $form, 'Cobranca_Logradouro' ),   'Rua billing', '' );
    is( get_value_for( $form, 'Cobranca_DDD_Telefone' ), '11',          '' );
    is( get_value_for( $form, 'Cobranca_Logradouro_Numero' ), '333', '' );
    is( get_value_for( $form, 'Cobranca_Logradouro_Complemento' ),
        'apto 50', '' );

    is( get_value_for( $form, 'Entrega_Nome' ),      'Nome Shipping',      '' );
    is( get_value_for( $form, 'Entrega_Email' ),     'email@shipping.com', '' );
    is( get_value_for( $form, 'Entrega_Documento' ), '999222111555',       '' );
    is( get_value_for( $form, 'Entrega_Logradouro' ), 'Rua shipping', '' );
    is( get_value_for( $form, 'Entrega_Logradouro_Numero' ), '334', '' );
    is( get_value_for( $form, 'Entrega_Logradouro_Complemento' ),
        'apto 40', '' );
    is( get_value_for( $form, 'Entrega_Bairro' ), 'Ships',         '' );
    is( get_value_for( $form, 'Entrega_Cidade' ), 'Shipping City', '' );
    is( get_value_for( $form, 'Entrega_Estado' ), 'Vila Shipping', '' );
    is( get_value_for( $form, 'Entrega_CEP' ),    '99900-099',     '' );
    is(
        get_value_for(
            $form,
            'Entrega_Pais'
        ),
        'Espanha',
        ''
    );
    is( get_value_for( $form, 'Entrega_DDD_Telefone' ), '13',        '' );
    is( get_value_for( $form, 'Entrega_Telefone' ),     '7770-0201', '' );

    is( get_value_for( $form, 'Cobranca_DDD_Celular' ), '15',         '' );
    is( get_value_for( $form, 'Cobranca_Celular' ),     '99900-9382', '' );
    is( get_value_for( $form, 'Entrega_DDD_Celular' ),  '14',         '' );
    is( get_value_for( $form, 'Entrega_Celular' ),      '99900-0000', '' );

    $antifraud->enviar_pedidos( $form );
}


warn " ENVIAR CODIGO INTEGRACAO TB ";

done_testing;
use Data::Printer;

sub get_value_for {
    my ( $form, $name ) = @_;
    warn ' =>' . $name;
    return $form->look_down( _tag => 'input', name => $name )->attr('value');
}
