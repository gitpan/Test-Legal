use Test::t;
use Test::Legal::Util 'load_meta';


#my $version = '5.01000';

my $dir     = $ENV{PWD} =~ m#\/t$#  ? 'dat' : 't/dat';

isa_ok load_meta($_), 'CPAN::Meta', $_    for  <$dir/META*>;

