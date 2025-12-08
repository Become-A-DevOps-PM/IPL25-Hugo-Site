+++
title = "How Web Applications Work"
description = "Understanding the client-server architecture, HTTP communication, and server-side rendering"
weight = 1
+++

# How Web Applications Work

Delivering dynamic content to users requires coordination between multiple systems. A browser requests a page, a server processes that request and generates a response, and the browser renders the result. Understanding this flow—and the components involved—enables informed decisions about application architecture and deployment.

## The Client-Server Model

Web applications operate on a request-response pattern. The **client** (typically a web browser) initiates communication by sending a request. The **server** receives that request, performs some processing, and returns a response. This exchange happens over HTTP (Hypertext Transfer Protocol), the standard protocol for web communication.

The client and server have distinct responsibilities. The client handles user interaction: capturing input, sending requests, and rendering responses visually. The server handles business logic: validating data, querying databases, applying rules, and constructing responses. This separation allows each side to be optimized for its specific concerns.

A single server can handle requests from many clients simultaneously. When a user submits a contact form, their browser sends a request to the server. The server processes that submission—perhaps storing data or sending an email—and returns a response. Other users submitting forms at the same time each receive their own response, independent of other requests.

## HTTP: The Communication Protocol

HTTP defines how clients and servers exchange messages. Each HTTP message consists of a request or response with headers (metadata) and an optional body (content).

### HTTP Requests

When a browser needs a resource, it sends an HTTP request containing:

- **Method**: The action to perform (GET to retrieve, POST to submit data)
- **Path**: The resource being requested (`/contact`, `/api/users`)
- **Headers**: Metadata like content type, cookies, authentication
- **Body**: Data being sent (for POST requests)

A form submission creates a POST request. The browser collects form field values, encodes them, and sends them to the server. The request might look like:

```http
POST /contact HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded

name=Alice&email=alice@example.com&message=Hello
```

### HTTP Responses

The server processes the request and returns a response containing:

- **Status code**: Indicates success (200), redirect (301, 302), client error (400, 404), or server error (500)
- **Headers**: Metadata including content type and caching directives
- **Body**: The actual content (HTML, JSON, images)

A successful response to a form submission might return HTML:

```http
HTTP/1.1 200 OK
Content-Type: text/html

<!DOCTYPE html>
<html>
<body><h1>Thank you for your message!</h1></body>
</html>
```

The browser receives this response and renders the HTML visually.

## Server-Side Rendering

When a server constructs HTML before sending it to the client, this is **server-side rendering**. The server executes application code, potentially queries a database, and uses that data to build the complete HTML page. The browser receives finished HTML ready to display.

### Templates and Dynamic Content

Servers use **templates** to generate dynamic HTML. A template contains static HTML structure with placeholders for dynamic values. When processing a request, the server fills those placeholders with actual data.

Consider a thank-you page after form submission. The template might contain:

```html
<h1>Thank You!</h1>
<p>Thank you for contacting us, {{ name }}.</p>
<p>We will respond to {{ email }} soon.</p>
```

The server replaces `{{ name }}` and `{{ email }}` with values from the form submission. If Alice submitted the form, the server generates:

```html
<h1>Thank You!</h1>
<p>Thank you for contacting us, Alice.</p>
<p>We will respond to alice@example.com soon.</p>
```

This complete HTML travels to the browser, which displays it without needing to know how it was generated.

Different frameworks use different templating syntaxes, but the concept remains the same: define HTML structure once, insert dynamic values at request time.

## Web Servers vs Application Servers

Two distinct server types handle web traffic, each optimized for different tasks.

### Web Servers

A **web server** handles HTTP connections and serves static content efficiently. When a request arrives for an image, CSS file, or JavaScript file, the web server retrieves the file from disk and returns it. Web servers like nginx excel at handling thousands of concurrent connections with minimal resource consumption.

Web servers can also act as **reverse proxies**, receiving all incoming requests and forwarding appropriate ones to backend services. This architecture places the web server at the network edge, handling SSL/TLS termination, request routing, and static file serving while delegating dynamic requests to application servers.

### Application Servers

An **application server** executes application code to generate dynamic responses. When a request requires business logic—processing a form, querying a database, applying rules—the application server runs the code that implements that logic.

Application servers exist for every major programming language and framework. They manage worker processes that handle requests independently, distribute incoming requests across workers, and handle process lifecycle concerns like restarting failed workers.

### Why Two Server Types?

Separating web serving from application execution provides several benefits:

**Efficiency**: Web servers handle static content without involving application code. Serving an image requires only disk I/O, not application execution.

**Scalability**: Each layer scales independently. More application servers handle increased dynamic request load; CDNs and caching reduce static content load.

**Security**: The web server provides a hardened network boundary. Only necessary traffic reaches the application server.

**Flexibility**: Application servers can be restarted or updated while the web server continues serving static content and queuing requests.

A typical production deployment places nginx in front, handling SSL, static files, and proxying. The application server runs behind nginx, executing application code for dynamic requests.

## The Role of the Reverse Proxy

A **reverse proxy** sits between clients and backend servers, forwarding requests and returning responses. Unlike a forward proxy (which clients configure to access external resources), a reverse proxy operates transparently—clients connect to it as if it were the final destination.

Reverse proxies provide:

**Load balancing**: Distributing requests across multiple application servers

**SSL termination**: Handling HTTPS encryption/decryption, reducing application server load

**Caching**: Storing responses to serve repeated requests without involving the backend

**Security**: Filtering malicious requests before they reach application code

**Compression**: Reducing response sizes for faster transmission

nginx commonly serves as a reverse proxy. Configuration directs certain paths to static files and proxies others to the application server:

```nginx
server {
    listen 80;
    server_name example.com;

    # Serve static files directly
    location /static/ {
        alias /var/www/app/static/;
    }

    # Proxy dynamic requests to application server
    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

This configuration serves static assets efficiently while routing dynamic requests to the application server.

## Request Flow in Production

Understanding the complete request path clarifies how components interact.

### Development: Direct Connection

During development, most frameworks include a built-in development server. This server listens for HTTP connections directly, allowing rapid iteration without additional infrastructure. A request to `http://localhost:5000/contact` reaches the application immediately.

This direct connection simplifies development but lacks production characteristics. Development servers typically handle one request at a time and lack the robustness required for public traffic.

### Production: Through Multiple Layers

In production, requests flow through multiple components:

1. **Client sends request**: Browser connects to the server's public IP
2. **Web server receives request**: nginx accepts the connection
3. **Static or dynamic?**: nginx checks if the request matches a static file
4. **Proxy to application server**: For dynamic requests, nginx forwards to the application server
5. **Application processes request**: A worker executes the application code
6. **Response returns**: The application returns HTML, which flows back through nginx to the client

This layered architecture handles concurrent requests efficiently, maintains security boundaries, and enables independent scaling of each component.

## Summary

Web applications coordinate clients and servers through HTTP. Clients send requests; servers process them and return responses. Server-side rendering uses templates to generate HTML dynamically, inserting data into page structures before sending to clients. Web servers like nginx handle connections and static content efficiently, while application servers execute code for dynamic requests. Production deployments typically combine both, with nginx as a reverse proxy forwarding dynamic requests to the application server. Understanding this architecture enables deploying applications that handle traffic reliably and scale with demand.
