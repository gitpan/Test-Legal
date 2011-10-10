use Test::t;
use Test::Legal::Util qw/find_author load_meta/;


#my $version = '5.01000';

my $dir     = $ENV{PWD} =~ m#\/t$#  ? 'dat' : 't/dat';

my $file = "$dir/META.yml";
my $meta = load_meta( $file );

is find_author($file), 'Ioannis Tambouras';
is find_author($meta), 'Ioannis Tambouras';


# Returns undef
ok ! find_author();
ok ! find_author(undef);
ok ! find_author('');
ok ! find_author('/etc');




