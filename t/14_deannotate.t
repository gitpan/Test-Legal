use Test::More 'no_plan';
use File::Copy;
use Test::Legal::Util qw/ default_copyright_notice deannotate_copyright is_annotated/;
use File::Find::Rule;

my $msg = '# Copyright by  bottle';

my $dir     = $ENV{PWD} =~ m#\/t$#  ? 'dat' : 't/dat';


my $num = my @files = ( "$dir/blue", "$dir/black", "$dir/red" );
note 'copy files';
copy $_ , $dir     for  map { (my $f=$_) =~ s{(/[^/]*$)}{/bak$1}; $f }  @files  ;
is is_annotated($_,$msg), 1, "$_: is_annotated"  for @files;

is deannotate_copyright( [@files], $msg), 3 ;  

note 'check1 for deannoted files';
is is_annotated($_,$msg), 0, "$_: is_annotated"  for @files;

unlink @files;
exit;

ok ! deannotate_copyright(['/tmp/hots']);
