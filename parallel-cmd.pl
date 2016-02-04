#!/usr/bin/env perl

use 5.010;
use Net::OpenSSH;
use Term::ANSIColor;

my @hosts = qw( root@10.0.0.33 root@10.0.0.34 );

my $cmd = q!echo 'PATH is '$PATH && echo 'HOME is '$HOME!;
say "\nrunning:"; print colored( "$cmd\n", 'blue' ); say "on: @hosts";


#my $cmd = 'for i in `seq 1 20`;do echo $i;sleep 3;done';

my %conn = map { $_ => Net::OpenSSH->new($_, async => 1) } @hosts;
my @pid;
for my $host (@hosts) {
    open my($fh), '>', "/tmp/out-$host.txt"
      or die "unable to create file: $!";
    push @pid, $conn{$host}->spawn({stdout_fh => $fh}, $cmd);
}

waitpid($_, 0) for @pid;
