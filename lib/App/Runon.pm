package App::Runon;
use 5.010;
use List::MoreUtils qw< uniq >;
use Term::ANSIColor;
use Data::Dumper;
use JSON::PP;
use App::Runon::Hotkey;
use open qw<:encoding(UTF-8)>;

=head1 NAME

App::Runon - dont know

=cut

@ISA = qw(Exporter);
@EXPORT = qw( show );
our $VERSION = '0.01';

use warnings;
use strict;

# for verbose output change RUNON_DEBUG to 1;
$ENV{RUNON_DEBUG} = 1;
my $config = read_config('.runon');
my %max_len = %{ max_len() };
my %c = ( default => 'white on_blue', select => 'blue on_white', );
my $joint = colored([$c{default}],' ');

sub read_config {
    my $path = shift;
    local $/;
    open(my $fh,"<", $path) || die "cant open $path: $!";
    my $json = <$fh>;
    my $p = decode_json $json;
}

sub max_len {
    my (@environment, @region, @hostname, %max_len) = ();

    for(@$config){ 
        push @environment, $_->{environment};
        push @hostname, $_->{hostname};
        push @region, $_->{region};
    }
    my $test = length join('', uniq @environment);
    say $test;
    $max_len{environment} = length( join('', uniq @environment) );
    $max_len{region} = length( join('', uniq @region) );
    $max_len{hostname} = length( join('', uniq @hostname) );
    \%max_len;
}



sub filter {
    my $keyword = shift;
    my( @filtered, %filter ) = ();
    my $keylength = length $keyword;

    say length join('', my @region_length = grep { $_->{environment} } @$config);

    die "min 3 characters required" if $keylength <= 2;
    if($keylength >= 3){
        say "keyword: " . substr( $keyword, 0, 3) if $ENV{RUNON_DEBUG};
        @filtered = grep { substr(lc $_->{application}, 0, 3) eq substr( lc $keyword, 0, 3) } @$config;
    } 
    if($keylength >= 4){
        say "keyword: " . substr($keyword, 3, 1) if $ENV{RUNON_DEBUG};
        @filtered = grep { substr( lc $_->{region}, 0, 1 ) eq substr(lc $keyword, 3, 1) } @filtered;
    }
    if($keylength >= 5){
        say "keyword: " . substr( $keyword, 4, 1) if $ENV{RUNON_DEBUG};
        @filtered = grep { substr( lc $_->{environment}, 0, 1 ) eq substr( lc $keyword, 4, 1) } @filtered;
    }
    return \@filtered, $keylength;
}

sub array_length {
        return length join('', @{$_[0]});
}



sub show {
    my $keyword = shift;
    my( @region, @environment, @host ) = ();
    my( $results, $keylength )  = filter($keyword);

    for(@$results){
        push @region, $_->{region};
        push @environment, $_->{environment};
        push @host, $_->{hostname};
    }
    # has to be uniq otherwise it would display AMER - AMER if there is App only in AMER region but on more environments
    @region = uniq @region; @environment = uniq @environment; 

    # add host from filtered host array until it wont fit terminal. Then add number of hosts that didnt fit.
    my $term_width  = int `tput cols`;
    my $host_line_colored = ' '; my $host_line; my $h = 0;
    my $host_strip = ' ';
    my $base_line = join(' ', ($$results[0]->{application}, join(' - ',@environment), join(' - ',@region), $host_strip));

    for( @host ){
        $host_line .= "$h$_\ ";
        my $line_width = length($base_line)  + length($host_line);

        say "term_width" . $term_width;
        say "host_line:" . $host_line;
        say "base_line:" . $base_line;
        say "base_line length:" . length $base_line;
        say "line_width:" . $line_width;

        if($line_width <= $term_width){
            if( $keylength == 5 ){ 
                $host_line_colored = $host_line_colored . colored([$c{select}],$h) . colored([$c{default}],$_);
            } else { 
                $host_line_colored = $host_line_colored . colored([$c{default}],' ') . colored([$c{default}],$_);
            } 
        } else { $host_strip = '+' }
        $h++;
    }
    $host_line_colored =~ s/^\ //;

    system("clear");
    if($keylength == 3){
        my $line = join( $joint, 
            ( colored([$c{default}], $$results[0]->{application}) , colored([$c{select}],join(' - ',@region)) , colored([$c{default}],join(' - ',@environment)), $host_line_colored, colored([$c{select}], $host_strip ) )
        );
        print $line . "\n";
    } 

    elsif($keylength == 4){
        my $line = join( $joint,
            ( colored([$c{default}], $$results[0]->{application}) , colored([$c{default}],join(' - ',@region)) , colored([$c{select}],join(' - ',@environment)) , $host_line_colored, colored([$c{select}], $host_strip ) )
        );
        print $line . "\n";
    }

    elsif($keylength == 5){
        my $line = join( $joint,
            ( colored([$c{default}], $$results[0]->{application}) , colored([$c{default}],join(' - ',@region)) , colored([$c{default}],join(' - ',@environment)) , $host_line_colored, colored([$c{select}], $host_strip ) )
        );
        print $line . "\n";
    }
}


#show("$ARGV[0]");

