#!/usr/bin/env perl
# Copyright (C) 2011, Ioannis
use strict; 
use warnings;
use v5.10;
use Getopt::Compact;
use Data::Dumper;
use File::Slurp;
use Test::Legal::Util qw/ check_license_files  write_LICENSE license_types /; 
use Log::Log4perl ':easy';
our $VERSION = '0.05';

use constant { 
	LOG_PARAM  => { File=>'STDOUT', level=>$INFO, layout=>'%m%n', category=>'main'},
	LOG_MOD    => [('main', 'Test::Legal', 'Test::Legal::Util')],
};

our   $o;
our  $opts;
BEGIN {
Log::Log4perl->easy_init( LOG_PARAM() , { %{LOG_PARAM()}, category=>'Test::Legal'} );

$o = new Getopt::Compact 
    modes  => [qw( yes )],
	args   => 'dir  [check|add|remove|t|list]',
	struct => [ 
            [[qw(t type)], 'license type'],
            [[qw(a author)], 'copyright holder'],
			[[qw(d debug)],'debug','',sub{(Log::Log4perl->get_logger($_))->dec_level for @{LOG_MOD()}}],
			[[qw(q quiet)],'quiet','',sub{(Log::Log4perl->get_logger($_))->level($FATAL)for@{LOG_MOD()}}],
			];
}
$opts = $o->opts;


use constant {  BASE   => shift || '.' ,
			    ACTION => shift||'check',
	          #  DIRS   => [qw/ script lib /],
};
use Test::Legal  qw/ disable_test_builder /,
                 license_ok=>{ base=>BASE ,
					           #actions => [qw/ fix /] ,
                 } ,
;

DEBUG 'Scanning '. BASE ;
given (ACTION) {
	when (/^add$/i)   { disable_test_builder;
	                    write_LICENSE  BASE , @{$opts}{'author','type'};
	                  }
	when (/^remove$/i){ disable_test_builder;
						unlink BASE.'/LICENSE'  or warn "$!\n" and exit 1;
						DEBUG "unkinked" ;
	                  }
	when (/^list$/i)  { disable_test_builder;
			            INFO join "\t", license_types
                      }
	when (/^check$/i) { disable_test_builder;
			            check_license_files( BASE );
                      }
	when (/^t$/i)     { license_ok ;
                      }
	default:            INFO	 $o->usage and exit; 
}

