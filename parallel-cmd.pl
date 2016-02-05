#!/usr/bin/env perl

use 5.010;
use Net::OpenSSH;
use Term::ANSIColor;

my @hosts = qw( root@10.0.0.33 z8@10.0.0.36 z@10.0.0.35 );
my $module = $ARGV[0];

# needs rewrite; $cmd shoud be @cmd w few default exports etc
#my $cmd = qq!source .cypm && export PATH=/usr/local/bin:\$PATH && cpan $module!;

my $cmd = q!source ./.cypm && export PATH="/usr/local/bin:$PATH" && mkdir -p _build_/!.qq!$module!.q! && cpanm -L _build_/!.qq!$module!.qq! $module!;

# parallel test; uncoment below and tail /tmp/out-$host.txt on local host
#my $cmd = 'for i in `seq 1 20`;do echo $i;sleep 3;done';

# say info where is command running; put command string into separate line
say "\nrunning:"; print colored( "$cmd\n", 'blue' ); say "on: @hosts";


my %conn = map { $_ => Net::OpenSSH->new($_, async => 1) } @hosts;
my @pid;
for my $host (@hosts) {
    open my($fh), '>', "/tmp/out-$host.txt"
      or die "unable to create file: $!";
    push @pid, $conn{$host}->spawn({stdout_fh => $fh}, $cmd);
}

waitpid($_, 0) for @pid;
