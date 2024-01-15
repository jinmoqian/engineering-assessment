# Engineering Challenge

This is a test for job.

## How to run

For perl version, run it by

 * perl main.pl

For PHP version(swoole is needed), run it by 

* php main.php 

It will start a process and listen to :8080. You can visit it in browser by [http://localhost:8080/](http://localhost:8080/).

## APIs

|API|Parameters|Introduction|
|--|--|--|
|/hello||Do nothing but returns a "Hello"|
|/find|keyword=?|Filter by keyword. It finds in Applicant, Address and FoodItems columns|
|/coupon||Get a coupon randomly to demostraste a long request, or [comet](https://en.wikipedia.org/wiki/Comet_(programming))|

## Technologies

For per version, I studied some frameworks to run a web server.

* HTTP::Server::Simple. It is excessively simple. It runs in single process and single thread, so it can't give a long request support.
* Catalyst. It is too heavy for this demo.

I didn't find a good framework, so I wrote a simple webserver by myself. You can see it in perlver/server.pm. I didn't choose IO::Epoll as the model because I am not sure the program must be run under Linux. So I choosed POSIX model, listen/accept. It could run in any OS.

For PHP version, it's lucky that I have swoole. It's much more easier to build a long request supported web server.

The frontend do request by ajax.

The map is supported by Bing Maps.

The icon is from https://www.flaticon.com/free-icon/food-truck_683071. It is free for personal and commercial use.
