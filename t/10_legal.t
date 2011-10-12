

use Test::Legal  license_ok   => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' } ,
                 copyright_ok => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' } ,
;

         

license_ok;
copyright_ok;

