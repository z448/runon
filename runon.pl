#!/usr/bin/env perl

# rep https://gist.github.com/z448/45024574e7724c2d5847

use JSON;

$json = JSON->new->allow_nonref;
my $arg;
if ($ARGV[0]) {
    $arg = uc($ARGV[0]);
}
if ($ARGV[0] eq '-h') {
    &help; exit;
} else { print "$nicej"; }
my (@envapps, @regapps, @appname);
my $argL = length($arg);
$arg =~ s/(...)(.)?(.)?(.)?/$1$2$3$4/;
my ($app, $reg, $env, $host) = ($1,$2,$3,$4);
my $fn = "$ENV{'HOME'}\/nps\/etc\/\.apps\.json";
my $jdata;
{
        open(my $fh, '<:encoding(UTF-8)', $fn) or die;
        local $/ = undef;
        $jdata = <$fh>;
        close $fh;
}
$pdata = $json->decode( $jdata );
$nicej = $json->pretty->encode( $pdata );
if ($argL >= 3) {
    @appname = grep { $_->{'application'} =~ /^$app.*/ } @$pdata;
    } if ($argL >= 4) {
            @regapps = grep { $_->{'region'} =~ /$reg.../ } @appname;
        } if ($argL >= 5) {
            @envapps = grep { $_->{'env'} =~ /$env.?/ } @regapps;
        }
if ($argL==3) {foreach (@appname){ print "$_->{'application'}\ \> \ $_->{'hostname'}\n"; status(\@appname)}};
if ($argL==4) {foreach (@regapps){ print "$_->{'application'}\ \> \ $_->{'region'}\ \>\ $_->{'hostname'}\n"; status(\@regapps)}};
if ($argL==5) {foreach (@envapps){ print "$_->{'application'}\ \> \ $_->{'region'}\ \>\ $_->{'env'}\ \>\  $_->{'hostname'}\n"; status(\@envapps)}};
if ($argL==6) {for ($envapps[$host]){ system("sshrc $_->{'username'}\@$_->{'hostname'}\n") }};

sub status {
    my $range = shift;
    if ($ARGV[1] eq '-s') {
    foreach (@$range){ print "$_->{'application'}\ \n \ $_->{'status'}\n" };
    }
}

if ($ARGV[1] eq '-s') { &status }

if ($argL==0) { system(&help) }
sub help {
    print "QUICK HELP\n(use 'perldoc runon' for more detailed help)\n\n";
    print "\ \ \ usage: runon [app][r][e]\n\ \ \ \ \ \ \ [app] - first 3 characters of application name; e.g: Puma = pum";
    print "\n\ \ \ \ \ \ \ [r] - first character of region; e.g: amer = a";
    print "\n\ \ \ \ \ \ \ [e] - first character of enviroment e.g: sit = s\n";
    print "\n";
}

=head1 NAME
            runon CLI tool for remote execution of local command on group of servers filtered by keyword
.

=head1 SYNOPSIS
            runon [FILTER] [/PATH/TO/SCRIPT]
                    OR
            runon [where] [what]
.

=head1 DESCRIPTION
            All parameters are optional, i.e: without providing one it will output list of all nps hosts.
            Passing one parameter it'll list hostname based on pattern. Use it to narrow down list of hostnames
.
            FILTER ($1) is a string to be used as PATTERN which narrows down the list of hostnames on output
.
                    PATTERN
                            app name    - first 3 characters of appname ( e.g: batman = bat )
                            region      - first character of region (e.g: a or e )
                            environment - first character of env (e.g: s,q,u,g)
                            host number - from 0 to 9
.
            PATH ($2) is a local path of script to be copied and executed on group of remote hosts (e.g:  /home/user/myscript )
.

=head1 EXAMPLES
            runon bat       list all Batman servers
            runon bata      list all AMER Batman servers
            runon bataq     same as above but only QA environment
            runon bataq0    list first hostname from list above (AMER QA Batman - first server on the list)
