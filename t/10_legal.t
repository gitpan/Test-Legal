

use Test::Legal  license_ok   => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' , actions=>['fix']} ,
                 copyright_ok => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' , actions=>['fix']} ,
;

         

license_ok;
copyright_ok;

