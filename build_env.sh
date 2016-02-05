#!/usr/bin/env perl

use 5.010;
use warnings;
use strict;

use File::Find;
use Term::ANSIColor;

my @directories = ('_build_');
my $current_dir = '_build_';
my @dir_content  = ();

find(\&wanted,  @directories);

sub wanted {
    #print "$File::Find::dir\-\-\>" unless $current_dir = "$File::Find::dir";
    if ( $current_dir eq $File::Find::dir ){
        push @dir_content, $_;
    } else {
        print colored("$File::Find::dir \-\>", 'blue')."\n";
        say "@dir_content";
        @dir_content = ();
        $current_dir = $File::Find::dir;

       # print "$_\ ";
    }
}

