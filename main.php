<?php
use Swoole\Http\Server;
use Swoole\Coroutine;
require 'phpver/database.php';

$db = new Database();
$funcs = [
    "/" => function($request, $response){
        $response->header('Content-Type', 'text/html; charset=utf-8');
        $c = file_get_contents(__DIR__ . "/statics/index.html");
        $response->end($c);
    },
    "/statics/jquery.js" => function($request, $response){
        $response->header('Content-Type', 'text/plain; charset=utf-8');
        $c = file_get_contents(__DIR__ . "/statics/jquery-3.7.1.js");
        $response->end($c);
    },
    "/favicon.ico" => function($request, $response){
        $response->header('Content-Type', 'text/image; charset=utf-8');
        $c = file_get_contents(__DIR__ . "/statics/favicon.ico");
        $response->end($c);
    },
    "/hello" => function($request, $response){
        $response->header('Content-Type', 'text/plain; charset=utf-8');
        $response->end("hello");
    },
    "/find" => function($request, $response){
        global $db;
        $response->header('Content-Type', 'text/json; charset=utf-8');
        $ret = json_encode($db->find($request->get["keyword"]));
        $response->end($ret);
    },
    "/coupon" => function($request, $response){
        global $db;
        Coroutine::create(function()use($request, $response, $db){
            Coroutine::sleep(rand(1, 20));
            $response->header('Content-Type', 'text/json; charset=utf-8');
            $ret = json_encode($db->random_one());
            $response->end($ret);
        });
    },
];

$http = new Swoole\Http\Server('0.0.0.0', 8080);
$http->on('Request', function ($request, $response) {
    global $funcs;
    $f = $request->server['path_info'];
    if( isset($funcs[$f]) ){
        $f = $funcs[$f];
        if($f){
            $f($request, $response);
        }else{
            $response->status(404, "Not found");
        }
    }else{
        $response->status(404, "Not found");
    }
});

$http->start();
