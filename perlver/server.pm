package server;
use strict;
use Socket;
use POSIX ":sys_wait_h";;

$SIG{CHLD} = sub {
    while( ( my $child = waitpid( -1, WNOHANG ) ) > 0 ) {
    }
};


sub extract_params{
    my $s = shift;
    my @cs = split /\?/, $s;
    my $path;
    my $query_string;
    my $params={};
    if (scalar @cs == 2){
        $path = $cs[0];
        $query_string = $cs[1];
        my @ps = $query_string =~ /([^&\=]+)(?:(?:\=([^&]*))&?)?/g;
        while (@ps){
            my $key = shift @ps;
            my $val = shift @ps;
            $params->{$key} = $val;
        }
    }else{
        $path = $cs[0];
    }
    return ($path, $query_string, $params);
}

sub run_server{
    my $pkg = shift;
    my $port = shift;
    my $handlers = shift;
    my $socket;
    socket($socket,PF_INET,SOCK_STREAM,(getprotobyname('tcp'))[2]) or die "socket: $!";;
    setsockopt($socket, SOL_SOCKET, SO_REUSEADDR, 1) or die "setsockopt: $!";
    bind($socket, sockaddr_in($port, INADDR_ANY)) or die "bind: $!";
    listen($socket, 10);
    $| = 0;
    while(1){
        my $accept_ret = accept(my $s, $socket);
        if (!$accept_ret){
            next;
        }
        if (my $pid=fork()){
        }else{
            my $path;
            my $query_string;
            my $params;
            while(my $line=<$s>){
                if ($line =~ /GET ([\S]+)/) {
                    $path = $1;
                    ($path, $query_string, $params) = extract_params($path);
                }elsif ($line eq "\r\n"){
                    last;
                }
            }
            my $handle = $handlers->{$path};
            if($handle){
                $handle->($s, $path, $query_string, $params);
            }else {
                print "No handler: ", $path, "\n";
            }
            print "Done:", $path, "\n";
            close($s);
            exit(0);
        }
    }
}

sub output_json_header{
    my $pkg = shift;
    my $s = shift;
    $pkg->output_http_header($s, "text/json");
}
sub output_plain_header{
    my $pkg = shift;
    my $s = shift;
    $pkg->output_http_header($s, "text/plain");
}
sub output_html_header{
    my $pkg = shift;
    my $s = shift;
    $pkg->output_http_header($s, "text/html");
}
sub output_http_header{
    my $pkg = shift;
    my $s = shift;
    my $type = shift;
    send($s, "HTTP/1.1 200\r\n", 0) or die "send $!";
    send($s, "content-type: " . $type . ";\r\n", 0) or die "send $!";
    send($s, "charset: utf-8;\r\n", 0) or die "send $!";
    send($s, "\r\n",0) or die "send $!";
}
1;
