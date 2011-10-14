use Test::More;

use Test::Legal  '-core', 
                 defaults => { };
;

BEGIN{
	can_ok 'main','license_ok';
	can_ok 'main','copyright_ok';
}

use namespace::clean;         
no  namespace::clean;

use Test::Legal  '-core' => { -prefix => 'w_'}, 
;


BEGIN{
	can_ok 'main','w_license_ok';
	can_ok 'main','w_copyright_ok';
}
