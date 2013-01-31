

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Business::AntiFraud::Gateway::ClearSale::M',
    VERSION_FROM => 'lib/Business/AntiFraud/Gateway/ClearSale/M.pm', # finds \$VERSION
    AUTHOR       => 'Hernan Lopes (hernanlopes@gmail.com)',
    ABSTRACT     => 'Interface perl para M-ClearSale',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
