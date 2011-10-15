use Test::More;


use Test::More;

use Test::Legal  #license_ok   => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' , actions=>['fix']} ,
                 #copyright_ok => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' , actions=>['fix']} ,
                 -core => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' , actions=>['fix']} ,
                 defaults => { base=> $ENV{PWD} =~ m#\/t$#  ? '..' : '.' , actions=>['fix']} ,
;
BEGIN {
    can_ok 'main','license_ok';
    can_ok 'main','copyright_ok';
}

use namespace::clean;
 no namespace::clean;

BEGIN { $::dir  = $ENV{PWD} =~ m#\/t$#  ? '..' : '.' ; }

use Test::Legal  copyright_ok => {  dirs=> [qw/ sctipt lib /] },
	             'license_ok',
                 defaults     => { base=> $::dir, actions => [qw/ fix /] }
;         

BEGIN {
    can_ok 'main','license_ok';
    can_ok 'main','copyright_ok';
	
}


