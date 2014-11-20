#!usr/bin/perl
#Pastebin downloader 0.2
#by ..:: crazyjunkie ::.. 2014

use LWP::UserAgent;
use URI::Split qw(uri_split);
use HTML::LinkExtor;

my $nave = LWP::UserAgent->new;
$nave->agent(
"Mozilla/5.0 (Windows; U; Windows NT 5.1; nl; rv:1.8.1.12) Gecko/20080201Firefox/2.0.0.12"
);
$nave->timeout(10);

my $se = "downloads_pastebin";

unless ( -d $se ) {
    mkdir( $se, "777" );
}

chdir $se;

print "\n.:: Pastebin downloader 0.2 ::..\n";

unless ( $ARGV[0] and $ARGV[1] ) {
    print "\n[+] Sintax : $0 < -single / -page > <url>\n";
}
else {
    print "\n[+] Searching ...\n";
    if ( $ARGV[0] eq "-single" ) {
        download_this( $ARGV[1] );
    }
    if ( $ARGV[0] eq "-page" ) {
        download_all( $ARGV[1] );
    }
}

print "\nby .:: crazyjunkie ::.. 2014\n";

sub download_all {

    my $page = shift;

    my $code = toma($page);
    chomp $code;

    my @links_all = repes( get_links($code) );

    for my $page_down (@links_all) {
        download_this($page_down);
    }

}

sub download_this {

    my $page   = shift;
    my $titulo = "";
    my $num    = "";

    print "\n[+] Checking : $page\n";

    my $code = toma($page);

    if ( $page =~ /http:\/\/(.*)\/(.*)/ ) {
        $num = $2;

        if ( $code =~ /<div class="paste_box_line1" title="(.*)">/ ) {
            $titulo = $1;

            print "[+] Downloading : http://pastebin.com/download.php?i=$num\n";

            if (
                download(
                    "http://pastebin.com/download.php?i=$num",
                    $titulo . ".txt"
                )
              )
            {
                print "[+] File Downloaded !\n";
            }
            else {
                print "[-] Error\n";
            }

        }
    }

}

sub download {

    if ( $nave->mirror( $_[0], $_[1] ) ) {
        if ( -f $_[1] ) {
            return true;
        }
    }
}

sub repes {
    my @limpio;
    foreach $test (@_) {
        push @limpio, $test unless $repe{$test}++;
    }
    return @limpio;
}

sub toma {
    return $nave->get( $_[0] )->content;
}

sub get_links {

    $test = HTML::LinkExtor->new( \&agarrar )->parse( $_[0] );
    return @links;

    sub agarrar {
        my ( $a, %b ) = @_;
        push( @links, values %b );
    }
}
