# How the web works

TODO: Put some sort of quote in about documents which are linked
together.

The world wide web works on a "client-server" architecture. The client is usually
a browser (but there are plenty of other types of web client). The server is some
specialised software running somewhere on a machine that you have access to (either
through your local network or the internet).

Your web client sends a request to the server using a protocol called HTTP (the
HyperText Transfer Protocol). The web server processes that request and returns
an appropriate response. Your web client processes that response and takes the
appropriate action. In many cases, the response will consist of a web page. In these
cases, your web clinet (probably a browser) will parse the response and display
the web page to you.

Web pages are created using three technologies.

* HTML is the mark-up language that describes the content of your page.
* CSS sits on top of HTML and describes how your content should be displayed.
* Javascript is a programming language that adds interactice functionality to your 
web page.

We will look at all of these technologies in more detail below.

## HTTP

Under the hood, the web is all about the HyperText
Transfer Protocol. HTTP is the means by which a client (such as
a web browser, or a search engine bot) can ask a server for 
something and get a response which either includes whatever was
requested or a message that says something was wrong with the
request.

### Anatomy of a request

Let's take a look at an HTTP request.

    GET / HTTP/1.1␤␍
    Host: example.com␤␍
    ␤␍

#### The Request-Line

The first line is the *Request-Line*. This has three parts.

The request method (`GET`) describes what you want to do to the resource.

The request URI (`/`) identifies which resource the request is for.

The protocol version (`HTTP/1.1`) states the version of HTTP in use. 
1.1 has been around since the 90s. Version 2 is under development
but it will be a long time before we see it in production.

The line then ends with a carriage return **and** a line feed
(`CRLF`).

After the request line we have the HTTP request headers.

#### HTTP Headers

Both requests and responses come in two parts. A set of headers and then, sometimes, some content.

The format of a header is very simple:

1. A name
2. A colon (`:`)
3. A value

There are lots of different headers in HTTP, and more from 
extensions, and we'll cover the more important ones throughout the 
book.

##### The Host header

If this was HTTP 1.0 then we wouldn't need to send any headers, but IPv4 addresses are a
precious commodity and we often have multiple websites hosted on a 
single computer with a single network interface, all with their own
hostname. 

HTTP 1.1 makes it mandatory to state which website the request is for
using a header.

    Host = "Host" ":" host [ ":" port ] ;

TODO: http://tools.ietf.org/html/rfc2616#section-5.2 - Read this 
properly. Can the host header be omitted if an absolute URI is in 
the header? Rephrase the bits about the Host header if that is an
option.

#### Ending the header

Finally, the request header is ended by two `CRLF` in a row. 

## HTML, CSS & Javascript

## Web Servers

