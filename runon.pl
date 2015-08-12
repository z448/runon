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
if ($argL==3) {foreach (@appname){ print "$_->{'application'}\ \> \ $_->{'hostname'}\n" }};
if ($argL==4) {foreach (@regapps){ print "$_->{'application'}\ \> \ $_->{'region'}\ \>\ $_->{'hostname'}\n" }};
if ($argL==5) {foreach (@envapps){ print "$_->{'application'}\ \> \ $_->{'region'}\ \>\ $_->{'env'}\ \>\  $_->{'hostname'}\n" }};
if ($argL==6) {for ($envapps[$host]){ system("ssh $_->{'username'}\@$_->{'hostname'}\n") }};
if ($argL==7) {foreach (@envapps){ print "$_->{'application'}\ \n \ $_->{'status'}\n" }};

if ($argL==0) {print $nicej}
sub help {
    print "usage: runon [app][reg][env]\n\ \ \ \ \ \ \ [app] - first 3 characters of application name; e.g: Puma = pum";
    print "\n\ \ \ \ \ \ \ [reg] - first character of region; e.g: amer = a";
    print "\n\ \ \ \ \ \ \ [env] - first character of enviroment e.g: sit = s\n";
}

=head1 NAME
           runon    CLI tool for remote command execution on group of servers filtered by keyword
=head1 SYNOPSIS
       runon [filter] [/path/to/script]
       OR
       runon [where] [what]
=head1 DESCRIPTION
       All parameters are optional, i.e: without providing one it will list of all nps hosts in json
       - filter ($1) is made of string which narrow donw list of hostnames output
           Filter pattern
           APPNAME - first 3 characters of appname
           REGION  - first character of region (i.e: a or e )
           ENV     - first character of env (i.e: s,q,u,g)
           HOST_Nr - from 0 to 9
       - path ($2) is path to script which will be executed on remote hosts
=head1 EXAMPLES
              runon bat           list all Batman servers
          runon bata          list all AMER Batman servers
          runon bataq         same as above but only QA environment
          runon bataq0        list first hostname from list above (AMER QA Batman - first server on the list)
