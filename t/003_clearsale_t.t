# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use warnings;
use strict;
use Test::More;
use Data::Printer;

BEGIN { use_ok('Business::AntiFraud'); }

#my $object = Business::AntiFraud->new ();
#isa_ok ($object, 'Business::AntiFraud');
use Business::AntiFraud;
use DateTime;

my $antifraud = eval {
    Business::AntiFraud->new(
        codigo_integracao   => '4FDAE0FD-6937-4463-A2D2-84FFB48A71E0',
        sandbox             => 1,
        gateway             => 'ClearSale::T',
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

isa_ok( $antifraud, 'Business::AntiFraud::Gateway::ClearSale::T' );

my $pedido_num = 'P3D1D0-ID-'.int rand(999999);
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
        pedido_id => $pedido_num,
        data      => $data,
        parcelas  => 2,
        tipo_de_pagamento => 1,
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

sub atualizar_status {
    my ( $antifraud, $pedido_id, $status ) = @_;
    return $antifraud->atualizar_status( $pedido_id, $status );
}

sub enviar_pedido {
    my ( $antifraud,  $form ) = @_;
    return $antifraud->enviar_pedido( $form );
}


done_testing;

sub get_value_for {
    my ( $form, $name ) = @_;
    return $form->look_down( _tag => 'input', name => $name )->attr('value');
}
