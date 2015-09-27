#!/usr/bin/env perl
# rep https://gist.github.com/z448/45024574e7724c2d5847
# git clone https://gist.github.com/45024574e7724c2d5847.git

use JSON;
use Net::OpenSSH;
use Term::ANSIColor;
use IO::All;
use Term::ReadKey;
use feature 'say';

$json = JSON->new->allow_nonref;
my $arg;
if ($ARGV[0]) {$arg = uc($ARGV[0])}

my $argL = length($arg);
$arg =~ s/(...)(.)?(.)?(.)?/$1$2$3$4/;
my ($app, $reg, $env, $host) = (qr/$1/,qr/$2/,qr/$3/,qr/$4/);

my $fn = "$ENV{'HOME'}\/nps\/etc\/\.apps\.json";
my $jdata;
{
        open(my $fh, '<:encoding(UTF-8)', $fn) or die;
        local $/ = undef;
        $jdata = <$fh>;
        close $fh;
}

$pdata = $json->decode($jdata);
sub jane {
    say $json->pretty->encode($pdata);
}

#fiter first param
sub chopL {
    #&help and last unless ( defined $ARGV[0]);
    if ($argL >= 3) {@data = grep { $_->{'application'} =~m/^${app}.*?/ } @$pdata}
    if ($argL >= 4) {@data= grep { $_->{'region'} =~m/^${reg}.../ } @data}
    if ($argL >= 5) {@data = grep { $_->{'env'} =~ m/^${env}.?.?/ } @data}
    relay(\@data);
   }

#relay action based on parameters
sub relay {
    my $data = shift;
    if ( !defined $ARGV[1]) {
        # minus arg0 subs goes here
        if ($ARGV[0]=~m/^\-/) {
            if ($ARGV[0] eq '--help' or $ARGV[0] eq '-h') {&help}
        } 
        #quick help if no arg passed
        unless(defined $ARGV[0]) {&h}
        #one arg subs goes here
        if ($argL>2 and $argL<6) {printer(\@$data, $argL)}
        if ($argL==6) {conn(\@$data)}
    } else {
            #two arg subs goes here
            if ($ARGV[1] eq '-s') {status(\@$data)} 
            elsif ($ARGV[1] eq '-f') {subAction{(\@$data)}
            } else {
                ossh(\@$data, $ARGV[1]);
            }
        }
    }
    
sub printer {
    $data=shift; my $argL=shift;
    ($wchar, $hchar, $wpixels, $hpixels) = GetTerminalSize();
    print $wchar, $hchar, $wpixels, $hpixels;
    my $clear='clear'; system($clear);#print "\n"x200;
    my $w='white on_blue'; my $c='blue on_black';$b='dark on_black';
        
                for(@host){$hosts{"$_->{'env'}\-$_->{'region'}"} .= "$_->{'hostname'}\ " if (($_->{'env'}=~/$env/) and ($_->{'region'}=~/$reg/));$h++}; 
     
                for(@$data){$ap="$_->{'application'}";$env="$_->{'env'}";$reg="$_->{'region'}"; $host="$_->{'hostname'}"; push @h," $host" }; 

                print colored(['blue on_black'], "|");
                if ($argL>=3){print colored([$w], " $ap ")}
                if ($argL>=4){print colored([$w]," $reg " )}else{print colored([$c],"  AMER|EMEA")};
                if ($argL==5){print colored([$w]," $env ")}else{print colored([$c],"  SIT|QA|UAT")}
                if (scalar@h==1){print ' ';  print colored(['blink on_black'],' [1]'); print colored([$c],' [')} else {
                print ' ['; print scalar @h; print ']';print colored(['blue on_black'], " [")}
                
                if (scalar @h<5){print colored([$b],"@h " )}else{print colored([$b], "$h[0] $h[1] $h[2] $h[3]".' ..')}
                print colored(['blue on_black'], "]");
    print "\n";
}

sub status {
    my $data = shift;
    for (@$data){ 
        print "$_->{'application'}\ \n \ $_->{'status'}\n";
        }
    }

sub ossh {
        my $data = shift;
        my $cmd = shift;
        for (@$data) {
            my $con = qq($_->{'username'}\@$_->{'hostname'});
            my $ssh = Net::OpenSSH->new($con);
            my @pty = $ssh->capture({stdin_discard => 1},"export PATH=~/nps/bin:\$PATH; echo `hostname`; $cmd");
            print @pty;
        }
}

sub conn {
        my $data = shift;
        #add check for tmux; do normal ssh if N/A
        #for ($$data[0]) {system(qq(sshrc -q $_->{'username'}\@$_->{'hostname'}))}
        for (@$data) { 
            print "$_->{'username'}\@$_->{'hostname'}";

            system(qq(tmux split-window -h "ssh $_->{'username'}\@$_->{'hostname'}")); 
            system(qq(tmux select-layout tiled > /dev/null));
        }
    }


sub subAction {

}
##################### start ###################
&chopL;

sub help {
        system("perldoc $0");
}

sub h {
    print color('white');print "\nQUICK HELP"; print color('reset');print "\n(use ";
    print color('white');print "--help"; print color('reset');
    print " for help in more detail)\n\n";
    print "\tUsage:\trunon ";
    print color('blue'); 
    print "[app]"; 
    print color ('yellow'); 
    print "[r]"; 
    print color ('magenta');
    print "[e]\n\n\t\t";
    print color('blue'); print "[app]";
    print color("reset");
    print "\tfirst 3 characters of application name; e.g: Puma = pum)\n\t\t";
    print color ('yellow');print "[r]"; print color('reset');
    print "\tfirst character of region; e.g: amer = a\n\t\t";
    print color('magenta'); print "[e]"; print color('reset');
    print "\tfirst character of enviroment e.g: sit = s";
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
            runon [FILTER] [COMMAND]
                     =
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

#NOTES
# fix perldoc - HTML2Pod.pm
# add -sub for paralel file copy
# add check if tmux is installed / if Y - nr of window splits = nr of hosts after filtered result;
#
