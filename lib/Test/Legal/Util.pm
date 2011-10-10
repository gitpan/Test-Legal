package Test::Legal::Util;
# Copyright (C) 2011, Ioannis

use v5.10;
use strict;
use warnings;
our $VERSION = '0.02';
#use Data::Show;
use File::Slurp 'slurp';
use CPAN::Meta;
use List::Util 'first';
use Software::License;
use Log::Log4perl ':easy';
use IO::Prompter;
use base 'Exporter';

our @EXPORT_OK = qw( 
	annotate_copyright          find_author      load_meta
	default_copyright_notice    is_annotated     deannotate_copyright
	howl_notice                 is_license_type  license_types license_text
	write_LICENSE
);
=pod

=head2  howl_notice
 Input: filename and message, or ''
 Output: commented text string 
 Constructs a (properly commented) notice message farmed in various ways, including
 reading from  filename, or even suppling a default. There is no way to receive a
 blank copyright notice.
=cut
sub howl_notice {
	my $msg = shift||undef;
	$msg  = -T ($msg||'') ? (slurp $msg||'',{err_mode=>'quiet'}) || undef
                          : $msg;
	$msg //= default_copyright_notice();
	$msg =~ s/^(?!#)/# /mgo  unless $msg =~ qr/^\s*$/om;
	$msg;
}
=pod

=head2  is_annotated
 Input: filename and message
 Output: True, if file is already annotated with this message;
         otherwise, false
=cut
sub is_annotated {
    my ($file, $msg) = @_ ;
	my $contents = slurp $file  or return;
	 () = $contents =~ /\Q$msg/gis ;
}
sub default_copyright_notice {
	my $geco =  ucfirst ([getpwuid $<]->[6] || getlogin);
	my $year =  1900 + [localtime]->[5];
	sprintf '%s %s, %s', '# Copyright (C)', $year, $geco ;
}
=pod

=head2  _annotate_copyright
 Annotates one file . 
 Assumptions: msg already validated
 Input: filename, copyright notice
 Output: TRUE on  file change, otherwise FALSE
=cut
sub _annotate_copyright {
    my ($file, $msg) = @_ ;
	return  unless -T $file ;
	# Don't annotate if already annotated
	return   if is_annotated($file,$msg);
    my $perms = ((stat($file))[2]) & 07777 ;
    #DEBUG  sprintf( "perms are %04o\n", $perms) ;
	open my ($in), '<', $file  or return;
	unlink $file;
	open my ($out), '>', "$file";
    chmod($perms | 0600, $out);
	print {$out} scalar <$in>;
	print {$out} $msg,"\n";
	print {$out}  <$in> ;
}
=pod

=head2  annotate_copyright
 Annotates one or more files . 
 Input: file (or arrayref of files), copyright notice
 Output: number of files annotated
=cut
sub annotate_copyright {
    my ($files, $msg) = @_ ;
	$msg //= default_copyright_notice;
	return unless $msg;
	return _annotate_copyright($files,$msg)  unless ref $files;
	my $i=0;
	_annotate_copyright($_,$msg) && $i++ for @$files;
	$i;
}
=pod

=head2  _deannotate_copyright
 Remove copyright from  one file . 
 Assumptions: msg already validated
 Input: filename, copyright notice
 Output: TRUE on  file change, otherwise FALSE
=cut
sub _deannotate_copyright {
    my ($file, $msg) = @_ ;
	return  unless -T $file ;
    my $perms = ((stat($file))[2]) & 07777 ;
    #DEBUG  sprintf( "perms are %04o\n", $perms) ;
	my $content = slurp $file or return;
	$content =~ s/\Q$msg\E//g ;
	open my ($out), '>', "$file";
    chmod($perms | 0600, $out);
	print {$out}  $content;
}
=pod

=head2  deannotate_copyright
 Removes copyright from one or more files . 
 Input: file (or arrayref of files), copyright notice
 Output: number of files deannotated
=cut
sub deannotate_copyright {
    my ($files, $msg) = @_ ;
	$msg //= default_copyright_notice;
	return unless $msg;
	return _deannotate_copyright($files,$msg)  unless ref $files;
	my $i=0;
	_deannotate_copyright($_,$msg) && $i++ for @$files;
	$i;
}
=pod

=head2  load_meta
 Input: filename
 Output: CPAN::Meta object
=cut
sub load_meta {
    my $_ = shift||return;
    -T and -r  and CPAN::Meta->load_file($_) ;
}
=pod

=head2  find_author
 Input:  filename or CPAN::Meta object
 Output: 1st author mentioned in CPAN::Meta. 
         Returns undef  on failure
=cut
sub find_author {
    my $meta = shift||return;
	$meta = load_meta($meta) unless UNIVERSAL::isa($meta,'CPAN::Meta');
	return unless $meta;
	return unless UNIVERSAL::isa($meta,'CPAN::Meta');
    my ($author) =  $meta->author or return '';
    $author =~ s/\s*<.*>\s*//;
    $author;
}
=pod

=head2  license_types

=cut
sub license_types {
	qw/ 
		AGPL_3       BSD          GFDL_1_3     LGPL_3_0     OpenSSL      Sun
		Apache_1_1   CC0_1_0      GPL_1        MIT          Perl_5       Zlib
		Apache_2_0   Custom       GPL_2        Mozilla_1_0  PostgreSQL
		Artistic_1_0 FreeBSD      GPL_3        Mozilla_1_1  QPL_1_0
		Artistic_2_0 GFDL_1_2     LGPL_2_1     None         SSLeay
	/;
}
=pod

=head2  is_license_type

=cut
sub is_license_type {
	my $type = (shift|| return);
	first { $type eq  $_  }  license_types()   or return;
}
=pod

=head2  license_text

Input: type of license (i.e. Perl_5), and name of copyright holder
Output: the specific license object

=cut
sub license_text {
	my ($type, $holder) = @_;
	return unless $type||'' =~ /^\w{2,16}$/o;
    $type = 'Software::License::'. ucfirst($type|| return);
	eval "use $type";
    return if $@;
	#$holder or $holder=find_author; TODO
	$type->new( { holder=>($holder||return)}  );
}
=pod

=head2  write_LICENSE

 Writes the LICENSE file
Input: 
Output: the specific license object

=cut
sub write_LICENSE {
	my ($file, $author, $type) = @_ ;
	$author //=  getlogin;
	$type //=  'Perl_5';
	#say "author=$author, type=$type";
	my $lok = is_license_type($type);
	DEBUG qq(Cheking type "$type".....)  . ($lok ? 'ok' : 'FAIL');
	$lok or INFO($::o->usage) and INFO( qq(The "list" command lists available licenses))  and exit 1 ;
	# find author
	$lok = license_text( $type, $author );
	DEBUG qq(Text available for "$type".....) . ($lok ? 'ok' : 'FAIL');
	$lok or INFO("License text not available") and  exit 1 ;
    unless ($::opts->{yes}) {
		 -T $file  ?  (prompt '-yes', 'Overide LICENSE?') ||  return  : 1;
    }
 	DEBUG 'Adding LICENSE file';
 	open my ($o), '>', $file or die$! ;
 	say {$o} $lok->fulltext;
}


1;
__END__

=head1 NAME

Test::Legal::Util -  Support module for Test::Legal

=head1 SYNOPSIS

  use Test::Legal::Util;

=head1 DESCRIPTION


=head2 EXPORT

None by default.

=head1 SEE ALSO

=head1 AUTHOR

Tambouras, Ioannis E<lt>ioannis@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Ioannis Tambouras

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
