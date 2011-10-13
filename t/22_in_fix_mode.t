#use Test::t ;

use Test::More;

BEGIN {
use Test::Legal license_ok=>{ base=> ($ENV{PWD} =~ m#\/t$#)  ? '..' : '.',
                              actions => [qw/ fix /] ,
                 } ,           
;                
}

*_values = \& Test::Legal::_values ;
*_in_fix_mode = \& Test::Legal::_in_fix_mode ;

can_ok 'Test::Legal','_in_fix_mode' ;


