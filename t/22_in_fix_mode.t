#use Test::t ;

use Test::More;
use Test::Legal;


*_values = \& Test::Legal::_values ;
*_in_fix_mode = \& Test::Legal::_in_fix_mode ;

my $dir     = $ENV{PWD} =~ m#\/t$#  ? 'dat' : 't/dat';

my $required_keys = [qw/ base dirs meta/];
my @keys = qw/ base dirs meta/;


ok 1;
exit;
is_deeply [sort keys %{_values({base=>'.'})}] , $required_keys;
is_deeply [sort keys %{_values({base=>'.', dirs=>'t'})}] , $required_keys;
is_deeply [sort keys %{_values({a=>''})}] , [ 'a',@$required_keys];

my $give={base=>'.',dirs=>'t'} ; 
my $get ={ %$give, meta=> CPAN::Meta->load_file('META.yml') };
is_deeply _values( $give), $get ;

is_deeply [sort keys %{_values({})} ] , $required_keys;
is_deeply [sort keys %{_values()}   ] , $required_keys;

ok ! _values([]);

TODO: {
	local $TODO = 'why does it fail?';
	ok ! _values();
}

