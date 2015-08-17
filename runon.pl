#!/usr/bin/env perl
# rep https://gist.github.com/z448/45024574e7724c2d5847
# git clone https://gist.github.com/45024574e7724c2d5847.git

use JSON;
use Net::OpenSSH;

$json = JSON->new->allow_nonref;
my $arg;
if ($ARGV[0]) {
    $arg = uc($ARGV[0]);
}
if ($ARGV[0] eq '-h') {
    &h; exit;
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

if (defined $ARGV[1]) {
if ($ARGV[1] eq '-s') {&status}
elsif ($ARGV[1] eq '-t') {&todo}
elsif ($ARGV[1] eq '-u') {&update}
#else {for ($envapps[$host]){ system("sshrc $_->{'username'}\@$_->{'hostname'} \'source ~/nps/bin/nps.env && $ARGV[1]\'\n") }
else {for ($envapps[$host]){ ossh($_->{'username'}, $_->{'hostname'}, $ARGV[1]) }
        }
}

sub ossh {
        my $user = shift;
        my $target = shift;
        my $cmd = shift;
        my $ssh = Net::OpenSSH->new("$user\@$target");
        #$ssh->system("export PATH=\$HOME/nps/bin"); # works
        my @rcvr = $ssh->capture("export PATH=~/nps/bin:\$PATH; $cmd");
        print @rcvr;
#implement 'find w follow symlinks'
# runon batas 'find -L ~ -iname "*.log"'
}

if ($argL==0) { system(&h) }

sub help {
        system("perldoc $0");
}

sub h {
    print "\nQUICK HELP\n(use --help for help in more detail)\n\n";
    print "\tusage:\trunon [app][r][e]\n\n\t\t[app]\tfirst 3 characters of application name; e.g: Puma = pum";
    print "\n\t\t[r]\tfirst character of region; e.g: amer = a";
    print "\n\t\t[e]\tfirst character of enviroment e.g: sit = s";
    print "\n\n";
}

sub todo {
    print "- if first option ends with number, then the number is item in array which i'll use as additional filter for whatever preceeds the nubmer";
    print "- get rid of JSON dependency or use JSON::Lite";
    print "- add option to source custom file on another side, right upon login";
}

sub update {
    $mepath = `which $0`;
    system("rm -r .git");
    system("curl -kLO `cat .runon`");
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
