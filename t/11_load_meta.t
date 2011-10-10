use Test::More 'no_plan';
use Test::Legal::Util 'load_meta';



my $dir     = $ENV{PWD} =~ m#\/t$#  ? 'dat' : 't/dat';

isa_ok load_meta($_), 'CPAN::Meta', $_    for  <$dir/META*>;

