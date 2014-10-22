#!/usr/bin/env perl

use strict; 
use warnings;
use v5.10;
use Getopt::Compact;
use Data::Dumper;
use File::Slurp;
use Test::Legal::Util qw/ howl_notice /;
use Log::Log4perl ':easy';
our $VERSION = '0.08';

use constant { 
	LOG_PARAM  => { File=>'STDOUT', level=>$INFO, layout=>'%m%n', category=>'main'},
	LOG_MOD    => [('main', 'Test::Legal')],
};

my   $o;
our  $opts;
BEGIN {
Log::Log4perl->easy_init( LOG_PARAM() , { %{LOG_PARAM()}, category=>'Test::Legal'} );

$o = new Getopt::Compact 
    modes  => [qw( yes )],
	args   => 'dir  [check|add|remove|t]',
	struct => [ 
            [[qw(c copyright)], 'copyright_noitce'],
			[[qw(d debug)],'debug','',sub{(Log::Log4perl->get_logger($_))->dec_level for @{LOG_MOD()}}],
			[[qw(q quiet)],'quiet','',sub{(Log::Log4perl->get_logger($_))->level($FATAL)for@{LOG_MOD()}}],
			];
}
$opts = $o->opts;


use constant {  BASE   => shift || '.' ,
			    ACTION => shift||'check',
	            DIRS   => [qw/ script lib /],
};
use Test::Legal  qw/ disable_test_builder annotate_dirs deannotate_dirs /,
                 copyright_ok=>{base=>BASE, dirs=> DIRS } ,
                 #copyright_ok=>{base=>BASE, dirs=> DIRS, actions=>['fix'] } ,
;


my @dirs = map { BASE .'/'. $_ } @{DIRS()} ;
DEBUG "Scanning @dirs ";
given (ACTION) {
	when (/^add$/i)   { my $msg = howl_notice($opts->{copyright} ) ;
						DEBUG 'Using copyright: "'. (substr $msg, 0, 40) . '"' ;
                        disable_test_builder;
				  	    INFO  sprintf '%s updated, %s remain', annotate_dirs( $msg, @dirs);
	                  }
	when (/^remove$/i){ my $msg = howl_notice($opts->{copyright} ) ;
						DEBUG 'Using copyright: "'. (substr $msg, 0, 40) . '"' ;
                        disable_test_builder;
					    INFO  sprintf '%s updated, %s remain', deannotate_dirs( $msg, @dirs);
	                  }
	when (/^check$/i) { my $msg = 'Copyright (C)';
                        DEBUG 'Using copyright: '. qq("$msg") ;
                        disable_test_builder;
					    INFO  "no Ⓒ : $_" for copyright_ok $msg; 
                      }
	when (/^t$/i)     { my $msg = 'Copyright (C)';
                        DEBUG 'Using copyright: '. qq("$msg") ;
					    copyright_ok  $msg; 
                      }
	default:            INFO	 $o->usage and exit; 
}

