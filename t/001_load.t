# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Business::AntiFraud::Gateway::ClearSale::M' ); }

my $object = Business::AntiFraud::Gateway::ClearSale::M->new ();
isa_ok ($object, 'Business::AntiFraud::Gateway::ClearSale::M');
my $inputs = $object->get_hidden_inputs();


