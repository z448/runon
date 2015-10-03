#!/usr/bin/env perl
# rep https://gist.github.com/z448/45024574e7724c2d5847
# git clone https://gist.github.com/45024574e7724c2d5847.git

use JSON;
use Net::OpenSSH;
use Term::ANSIColor;
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
        if ($argL==6) {con(\@$data)}
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
    my $clear='clear'; system($clear);#print "\n"x200;
    my $w='white on_blue'; my $c='white on_black';$b='dark on_black'; my $bb='blue on_white';
    my $blinki='blink on_yellow';
        
#                for(@host){$hosts{"$_->{'env'}\-$_->{'region'}"} .= "$_->{'hostname'}\ " if (($_->{'env'}=~/$env/) and ($_->{'region'}=~/$reg/));$h++}; 

    for(@$data){$ap="$_->{'application'}";$user="$_->{'username'}";$env="$_->{'env'}";$reg="$_->{'region'}"; $host="$_->{'hostname'}"; push @h," $host" }; 

    sub trimLine {
        my ($color)=@_;
        @x = qx(stty -a);
        @y = split(/;/, $x[0]);
        my $line=$y[2];
        #print "\nline is $line\n";

        sub baseLine {
            if($argL==3){return (47+length $ap)}
            if($argL==4){return (39+length $ap)}
            if($argL==5){return (30+length $ap)}
            #if ($argL==3){return (38+length $ap)}
        }
        #print "baseline is".&baseLine;print "\n";
        my @hostLine;
        $restLine=abs($line-&baseLine);
        my $chars;
        #print "\n\$restLine is " . $restLine . "\n";
            for (@h){
                    $chars .= $_;
                if (length $chars>$restLine){last}else{
                    push @hostLine, $_;
                }
            }
        sub lH {for(@hostLine){$hL.=$_};length $hL}
        $empty=$restLine-(&lH+scalar @hostLine); 
        #print "which leaves empty $empty\n";

        $trimLine=$line-$charsL+scalar @h; #nr of chars that needs to be trimmed from bar
        {
            use integer;
            my $items=scalar @h;
            $float=$restline/$items;
        }
        #print "$float";
        #print "\n";
        #print "$trimLine";
        if (scalar@h==1){print colored(['blink on_blue'], "\=> ")}
        #if ($argL==5 and scalar@h>1){
        $hNR=0;
            for (@hostLine){
                print colored(['blue on_white'], "$hNR");
                print colored([$color], "$_ ");
                $hNR++;
            }
        print colored([$color], "\ "x$empty);
        # print colored(["$w"],("\ "+$empty));
    }

        if (scalar@h >1 ){print colored(['blink on_red'], scalar@h); print colored(['white on_red'], " ")}else{print colored([$bb], "\  ")};
        if ($argL>=3){print colored([$w], " NPS |  ")}

        if ($argL>=3){print colored([$w], "$ap ");print colored([$w], "\|")}
        
        if ($argL==3){print colored([$c]," AMER");print colored(['blink']," -");print colored([$c]," EMEA ");print colored([$w], "\ ")};
        if ($argL>=4){print colored([$w],"  $reg ")};

        #print colored([$w], "\ ");

        if ($argL==3){print colored([$c]," SIT - QA - UAT ")};
        if ($argL==4){print colored([$c]," SIT");print colored(['blink']," -");print colored([$c]," QA");print colored(['blink']," -");print colored([$c]," UAT ")};
        
        if ($argL==5){print colored([$w],"| $env ")};
        &trimLine('white on_blue');
        #print colored([$w], "\ "x$empty);
        #  print colored([$w], " ");
        print colored(['blue on_white'], " ");
        
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
            print  "\n"x300;
        for (@$data) { 
            print "$_->{'username'}\@$_->{'hostname'}";
            system(qq(tmux split-window -h "ssh $_->{'username'}\@$_->{'hostname'}")); 
            system(qq(tmux select-layout tiled > /dev/null));
        }
    }

sub con {
    my $data = shift;
    print "$_->{'username'}\@$_->{'hostname'}";
    for (@$data) {system(qq(ssh -q $_->{'username'}\@$_->{'hostname'}))}}
        
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

=over 16

=item runon - CLI tool to easily connect and run commands on group of remote servers 

=back 

=head1 SYNTAX

=over 16

=item runon [FILTER] [COMMAND]

=item runon [where] [what]

=back

=head1 DESCRIPTION

=over 16

=item All parameters are optional, without providing one it will output list of all nps hosts. Passing one parameter it'll list hostname based on pattern. Use it to narrow down list of hostnames

=head2 SEARCH PATTERN ($1) 

=item - a string to be used when searching through hostnames which narrows down the list of hostnames on output

=item app name    - first 3 characters of appname ( e.g: batman = bat )
region      - first character of region (e.g: a or e )
environment - first character of env (e.g: s,q,u,g)
host number - from 0 to 9

=back 

=head2 CMD ($2)  

=over 20

- command executed on group of remote hosts (e.g:  /home/user/myscript )

=back 

=head1 EXAMPLES

=over 20

=item runon bat       list all Batman servers
=itemrunon bata      list all AMER Batman servers
runon bataq     same as above but only QA environment
runon bataq0    list first hostname from list above (AMER QA Batman - first server on the list)

=item NOTES

fix perldoc - HTML2Pod.pm
add -sub for paralel file copy
add check if tmux is installed / if Y - nr of window splits = nr of hosts after filtered result;

=back

=cut

