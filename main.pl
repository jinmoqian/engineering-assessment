use strict;
use Data::Dumper;
use JSON;

use lib './perlver';
use server;
use database;

sub read_static{
    my $file = shift;
    open(my $fh, "<", "./statics/" . $file) or die "Open file: $!";
    binmode($fh);
    my $buf;
    read($fh, $buf, 4 * 1024 * 1024) or die "Read file: $!";
    close $fh;
    $buf;
}

my $db = database->new();

server->run_server(8080, {
    "/" => sub{
        my $s = shift;
        server->output_html_header($s);
        my $buf = read_static("index.html");
        send($s, $buf, 0);
    },
    "/statics/jquery.js" => sub{
        my $s = shift;
        server->output_html_header($s);
        my $buf = read_static("jquery-3.7.1.js");
        send($s, $buf, 0);
    },
    "/favicon.ico" => sub{
        my $s = shift;
        server->output_html_header($s);
        my $buf = read_static("favicon.ico");
        send($s, $buf, 0);
    },
    "/hello" => sub{
        my $s = shift;
        my $path = shift;
        my $query_string = shift;
        my $params = shift;
        server->output_plain_header($s);
        my $json = JSON->new()->utf8;
        send($s, "hello", 0);
    },
    "/find" => sub{
        my $s = shift;
        my $path = shift;
        my $query_string = shift;
        my $params = shift;
        my $keyword = $params->{'keyword'};
        
        my $r;
        if ( $keyword eq ""){
            $r=[];
        }else{
            $r= $db->find($keyword);
        }
        my $json = JSON->new()->utf8;
        server->output_json_header($s);
        send($s, $json->encode($r), 0);
    },
    "/coupon" => sub{
        my $s = shift;
        my $path = shift;
        my $query_string = shift;
        my $data = $db->random_one();
        my $json = JSON->new()->utf8;
        sleep(rand(20));
        server->output_json_header($s);
        send($s, $json->encode($data), 0);
    },
});
