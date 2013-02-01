# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use warnings;
use strict;
use Test::More;

BEGIN { use_ok('Business::AntiFraud'); }

#my $object = Business::AntiFraud->new ();
#isa_ok ($object, 'Business::AntiFraud');
use Business::AntiFraud;

my $antifraud = eval {
    Business::AntiFraud->new(
        gateway        => 'ClearSale::M',
        receiver_email => 'hernanlopes@gmail.com',
        currency       => 'BRL',
        checkout_url   => '',
    );
};

ok( $antifraud, 'the object was defined' );
ok( !$@,        'no error' );

if ($@) {
    diag $@;
}

isa_ok( $antifraud, 'Business::AntiFraud::Gateway::ClearSale::M' );

my $cart = $antifraud->new_cart(
    {
        buyer => {
            email => 'hernan@cpan.org',
            name  => 'Mr. Buyer',
            phone => '',

            #==enderecos:
            address_street     => 'Rua Xyz',
            address_number     => 222,
            address_district   => 'Vila Mariana',
            address_complement => 'apto 50',
            address_zip_code   => '029012-020',
            address_city       => 'São Paulo',
            address_state      => 'SP',
            address_country    => 'Brazil',
        },
        shipping => {
            name             => 'Nome Shipping',
            email            => 'email@shipping.com',
            document_id      => '999222111222',
            address_street   => 'Rua shipping ',
            address_number   => '333',
            address_district => 'Ships',
            address_city     => 'Shipping City',
            address_state    => 'Vila Shipping',
            address_zip_code => '99900-022',
            address_country  => 'Brazil',
            phone            => '5670-0201',
            phone_prefix     => '11',
            celular          => '99900-2233',
            celular_prefix   => '11',
        },
        billing => {
            name             => 'Nome Billing',
            email            => 'email@billing.com',
            document_id      => '999222111222',
            address_street   => 'Rua billing ',
            address_number   => '333',
            address_district => 'Bills',
            address_city     => 'Bill City',
            address_state    => 'Vila Bill',
            address_zip_code => '99900-022',
            address_country  => 'Brazil',
            phone            => '5670-0201',
            phone_prefix     => '11',
            celular          => '99900-2233',
            celular_prefix   => '11',
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

    isa_ok( $item, 'Business::AntiFraud::Item' );
    is( $item->id, '1', 'item id is correct' );
    isnt( $item->price, 200.5, 'item price is not numeric' );
    is( $item->price,    '200.50', 'item price is correct' );
    is( $item->quantity, 10,       'item quantity is correct' );
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
    is(
        get_value_for( $form, 'receiver_email' ),
        'hernanlopes@gmail.com',
        'form value receiver_email is correct'
    );
    is( get_value_for( $form, 'currency' ),    'BRL'    , 'form value currency is correct' );
    is( get_value_for( $form, 'payment_id' ),  'pay123' , 'form value payment_id is correct' );
    is( get_value_for( $form, 'buyer_name' ),  'Mr. Buyer', 'form value buyer_name is correct' );
    is( get_value_for( $form, 'buyer_email' ), 'hernan@cpan.org', 'form value buyer_email is correct' );
    is( get_value_for( $form, 'encoding' ),    'UTF-8', 'form value encoding is correct' );

    is( get_value_for( $form, 'item_ID_1' ),    '1', 'form value item1_id is correct' );
    is( get_value_for( $form, 'item_Valor_1' ), '200.50', 'form value item1_price is correct' );
    is( get_value_for( $form, 'item_Qtd_1' ),   '10', 'form value item1_qty is correct' );

    is( get_value_for( $form, 'item_ID_2' ),    '02', 'form value item2_id is correct' );
    is( get_value_for( $form, 'item_Valor_2' ), '0.56', 'form value item2_price is correct' );
    is( get_value_for( $form, 'item_Qtd_2' ),   '5', 'form value item2_qty is correct' );

    is( get_value_for( $form, 'item_ID_3' ),    '03', 'form value item3_id is correct' );
    is( get_value_for( $form, 'item_Valor_3' ), '10.00', 'form value item3_price is correct' );
    is( get_value_for( $form, 'item_Qtd_3' ),   '1', 'form value item3_qty is correct' );

    is( get_value_for( $form, 'item_ID_4' ),    'my-id', 'form value item4_id is correct' );
    is( get_value_for( $form, 'item_Valor_4' ), '10.00', 'form value item4_price is correct' );
    is( get_value_for( $form, 'item_Qtd_4' ),   '1', 'form value item4_qty is correct' );

}

$antifraud->create_xml();

done_testing;
use Data::Printer;

sub get_value_for {
    my ( $form, $name ) = @_;
    warn ' =>' . $name;
    return $form->look_down( _tag => 'input', name => $name )->attr('value');
}
