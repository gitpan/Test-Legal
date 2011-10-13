package Test::Legal;
# Copyright (C) 2011, Ioannis
use v5.10;
use strict;
use warnings;
our $VERSION = '0.05';
use Sub::Exporter;

use CPAN::Meta;
#use Data::Show;
use File::Find::Rule;
use List::Util 'first';
use Log::Log4perl ':easy';
use List::Compare;
use IO::Prompter;
use Test::Builder::Module;
use Test::Legal::Util qw/ annotate_copyright   deannotate_copyright load_meta write_LICENSE/;


use Sub::Exporter -setup => { exports => [ qw/ disable_test_builder annotate_dirs deannotate_dirs/, 
 										  copyright_ok => \'_build_copyright_ok' ,
                                           license_ok   => \'_build_license_ok'],
                              groups  => { default => [qw/ copyright_ok license_ok /] }, };
use constant DEFAULTS =>  { base      => '.',
                            dirs      => [ qw/ lib script /],
};
my $tb = new Test::Builder ;
END   { $tb->done_testing; }

=pod 

=head1 NAME

Test::Legal -  Check for copyright notices in distribution files and for LICENSE file

=head1 SYNOPSIS

  use Test::Legal;         

  copyright_ok;
  license_ok;

  Or, here is the more refined way to acomplish the same thing
  use Test::Legal  copyright_ok => { base=> $dir, dirs=> [qw/ sctipt lib /] } ,
                   license_ok => { base=> $dir, actions => [qw/ fix /]},
  ;

  # Note,  The  "actions=>['fix']"  automatically tries to fix things before they are tested.
 


=head1 DESCRIPTION

 Checks for copyright notices in .pl and .pm distribution files, for author entry in META.yml
 or META.json, and for LICENSE file.

 You can add the copyright notices manually of use the copyright-injection.pl tool, supplied
 with this module, to add, to remove, or to check for notices automatically before tests.

 If "fix" mode is requested, some issues are automatically fixed so testing succeeds .
 Currently available only for license_ok but not for copyright_ok . See TODO list.

=head1 FUNCTIONS

=head2  disable_test_builder

=cut
sub disable_test_builder { 
	sub ok{}; sub done_testing{}; $tb=bless{} 
}
=pod

=head2  _values

=cut
sub _values {
    my $arg = shift;
	$arg //= {};
    return unless ref $arg eq 'HASH';	
    $arg = { %{DEFAULTS()}, %$arg };
    $arg = { %{DEFAULTS()}, %$arg };
    ($arg->{ meta }) = load_meta( $arg->{base} )  ;
    $arg->{meta} || die 'no META file in dir "'. $arg->{base}.qq("\n);
    $arg;
}
=pod

=head2  _in_fix_mode

 Assumptions: $arg exists and has been validated
 Input: the user arguments (a hashref)
 Output: TRUE if "fix" mode was specified, otherwise FALSE

=cut
sub _in_fix_mode {
    my $arg = shift;
    return unless ref $arg eq 'HASH';	
	return unless exists $arg->{actions};
	first {$_ =~ /^fix$/i}  @{$arg->{actions}};
}
=pod

=head2 set_of_files
=cut
sub set_of_files {
	my ($pat, @dirs) =  @_;
	$pat = qr/\Q$pat\E/i;
	my @all_files = File::Find::Rule->file->name(qr/.*(\.pm|\.pl)$/o)->in(@dirs);
	my @copyrighted = File::Find::Rule->file->name(qr/.*(\.pm|\.pl)$/o)-> grep($pat)->in(@dirs);
	List::Compare->new( \@all_files, \@copyrighted);
}
=pod

=head2  annotate_dirs
=cut
sub annotate_dirs {
	my ($pat, @dirs) =  @_;
	my $l = set_of_files ($pat, @dirs) ;
	my @without_c =  $l->get_unique  ;
	return (0,0) unless @without_c;
	DEBUG "Without copyright:\n\t" . join "\n\t", @without_c ;
	unless ($::opts->{yes}) {
		return (0,scalar @without_c) unless (prompt '-yes', 'Add copyright to all files that need it?') ;
	}
	DEBUG "Updating...";
	my $num = annotate_copyright(\@without_c, $pat) || 0;
	#verify
	$l = set_of_files ($pat, @dirs) ;
	my @remain = $l->get_unique; 
	DEBUG "Remain without copyrigh:\n\t" . join "\n\t", @remain  if @remain;
	($num, scalar @remain);
}
=pod

=head2  deanntate_dirs
=cut
sub deannotate_dirs {
	my ($pat, @dirs) =  @_;
	my $l = set_of_files ($pat, @dirs) ;
	my @with_c =  $l->get_intersection  ;
	return (0,0) unless @with_c;
	DEBUG "Have copyright:\n\t" . join "\n\t", @with_c ;
	unless ($::opts->{yes}) {
		return (0, scalar @with_c) unless (prompt '-yes', 'Remove copyright from all files?') ;
	}
	DEBUG "Updating...";
	my $num = deannotate_copyright(\@with_c, $pat) || 0;
	#verify
	$l = set_of_files ($pat, @dirs) ;
	my @remain = $l->get_intersection ;
	DEBUG "Remain copyrighted:\n\t" . join "\n\t", @remain  if @remain;
	($num, scalar @remain);
}
=pod

=head2  _build_copyright_ok
=cut
sub _build_copyright_ok {
    my ($class, $fun, $arg) = @_;
    $arg       = _values($arg);  
    my @dirs   = map {$arg->{base} . "/$_"} @{$arg->{dirs}};
    sub {
		my $pat = shift;
		$pat //= 'Copyright (C)';
        my $l= set_of_files($pat, @dirs);
        #$tb->ok( 0, $_ . ": $pat") for  $l->get_unique ;
        $tb->ok( 0, $_ ) for  $l->get_unique ;
        $tb->ok( 1, $_ ) for  $l->get_intersection;
		$l->get_unique;
    }
}
=pod

=head2  _build_license_ok
=cut
sub _build_license_ok {
    my ($class, $fun, $arg) = @_;
    $arg = _values($arg);  # keys : base, dirs , meta
    sub {
        my $has_file =  -f $arg->{base}.'/LICENSE' ;
		# attempt to fix?
	    if ((_in_fix_mode($arg)) && (!$has_file)) {
			$tb->note( 'added LICENSE' )  if  write_LICENSE($arg->{base}); 
		}
        $tb->ok( -f $arg->{base}.'/LICENSE', 'dist contains LICENSE file');
        $tb->ok( @{[$arg->{meta}->license]} > 0 , 'META mentions license');
    }
}

1;
__END__

=head1 EXPORT

    copyritht_ok;
    legal_ok;

=head1 EXPORT_OK

    disable_test_builder 
	annotate_dirs 
    deannotate_dirs

=head1 SEE ALSO

 copyright_injection.pl  ( provided with Test::Legal )

 Test::Copyright

=head1 AUTHOR

Tambouras, Ioannis E<lt>ioannis@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by Ioannis Tambouras

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.12.1 or,
at your option, any later version of Perl 5 you may have available.


=cut
