#!/usr/bin/perl

=begin metadata

Name: clear
Description: clear the screen
Author: Jeffrey S. Haemer
License:

=end metadata

=cut


use Term::Cap;
use strict;

my $OSPEED = 9600;
eval {
	require POSIX;
	my $termios = POSIX::Termios->new();
	$termios->getattr;
	$OSPEED = $termios->getospeed;
};

my $terminal = Term::Cap->Tgetent({OSPEED=>$OSPEED});
my $cl = "";
eval {
	$terminal->Trequire("cl");
	$cl = $terminal->Tputs('cl', 1);
};

print $cl;


=head1 NAME

clear - clear the screen

=head1 SYNOPSIS

clear

=head1 DESCRIPTION

=over 2

Look in the termcap database, find the character to clear the screen,
and emit it.

This is a direct lift from Section 15.7, B<Ringing the Terminal Bell>, from
I<Perl Cookbook>, with C<cl> substituted for C<vb>.

=back

=head1 TYPIST

Jeffrey S. Haemer

=head1 BUGS

B<clear> should probably take an argument, like B<yes>, that will
let users send arbitrary termcap sequences, with C<cl> as the default.

=head1 SEE ALSO

  Term::Cap(3)

=cut
