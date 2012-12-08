This is an example for embedding Lua into the logging phase of Nginx and building a simple log aggregation service.

Installation
============

One of the only dependencies not directly included in OpenResty is libpcre.
You can either install it from source, or use your distribution.
A modern version (>8.21) is recommended to leverage PCRE_JIT (faster regex), but it will still work with an older version.

In my case on Mac OS using [Homebrew](http://mxcl.github.com/homebrew/) :

    $ brew install pcre


Then download the latest OpenResty from this [page](http://openresty.org/#Download)
and compile it.
More up do date installation intruction can be found on the [Openresty install page](http://openresty.org/#Installation)

    $ wget http://agentzh.org/misc/nginx/ngx_openresty-1.2.4.11.tar.gz
    $ tar xvzf ngx_openresty-1.2.4.11.tar.gz
    $ cd ngx_openresty-1.2.4.11

Now let's finally compile it.
I found a slight issue that only happens on Mac OS while using hombrew, and I had to the configure line where to find my pcre library (`--with-ld-opt="-L/usr/local/lib"`)
This should get fixed in the next releases
    
    $ ./configure --with-luajit --with-ld-opt="-L/usr/local/lib"
    $ make
    
This will create a /usr/local/openresty/ directory that contains everything you need

    $ make install
    

Launching the demo server
=========================

Let's check that the Nginx we just compiled has all the necessary to run this example

    $ /usr/local/openresty/nginx/sbin/nginx -V

This will display all the module that Nginx has been built with, including ngx_lua-0.7.5 here
(the dev version of ngx_lua can be found [here](https://github.com/chaoslawful/lua-nginx-module))
    
    configure arguments: --prefix=/usr/local/openresty/nginx --add-module=../ngx_devel_kit-0.2.17 --add-module=../echo-nginx-module-0.41 --add-module=../xss-nginx-module-0.03rc9 --add-module=../ngx_coolkit-0.2rc1 --add-module=../set-misc-nginx-module-0.22rc8 --add-module=../form-input-nginx-module-0.07rc5 --add-module=../encrypted-session-nginx-module-0.02 --add-module=../srcache-nginx-module-0.16 --add-module=../ngx_lua-0.7.5 --add-module=../headers-more-nginx-module-0.19 --add-module=../array-var-nginx-module-0.03rc1 --add-module=../memc-nginx-module-0.13rc3 --add-module=../redis2-nginx-module-0.09 --add-module=../redis-nginx-module-0.3.6 --add-module=../auth-request-nginx-module-0.2 --add-module=../rds-json-nginx-module-0.12rc10 --add-module=../rds-csv-nginx-module-0.05rc2 --with-http_ssl_module

Now let's run Nginx with the configuration example.
(You don't need to run it as root, as the example doesn't listen on port 80)

    $ git clone https://github.com/mtourne/nginx_log_by_lua.git
    
The server will run until you send you hit Control+C

    $ /usr/local/openresty/nginx/sbin/nginx -p nginx_log_by_lua


Testing it
==========

    $ curl localhost:8080
 
If everything went right, you should see the sever response :

    Hello
    
    
Now, let's query our log aggregation port :

    $ curl localhost:6080
    
And here is the result :

    Since last measure:	1.0729999542236 secs
    Request Count:		1
    Average req time:	0 secs
    Requests per Secs:	0.93196648896742
    
    
As a final test you can try hammering your web application and see the log aggregation in action :
    
    ab -n 1000 -c 100 http://localhost:8080/ > /dev/null && echo && curl http://localhost:6080/
    
    Completed 100 requests
    Completed 200 requests
    Completed 300 requests
    Completed 400 requests
    Completed 500 requests
    Completed 600 requests
    Completed 700 requests
    Completed 800 requests
    Completed 900 requests
    Completed 1000 requests
    Finished 1000 requests
    
    Since last measure:	0.10899996757507 secs
    Request Count:		1000
    Average req time:	0.0012160038948059 secs
    Requests per Secs:	9174.3146557475
    

Beyond the example
==================

For the purpose of the example the code is very simple, but with very simple additions a json printer could be added to make the output easier to consume by other services (OpenResty does include the package [lua-cjson](http://www.kyne.com.au/~mark/software/lua-cjson.php))

We could also push the example further and aggregate logs to calculate timings similarly to `ab`, which displays what is the average request_time for the 90, 95, 99 percentile.

Happy Hacking!

