+++
title = "Application"
program = "IPL"
cohort = "25"
courses = ["SNS"]
description = "Web application concepts and architecture"
weight = 21
chapter = true
+++

# Application

Web applications coordinate clients and servers through HTTP. A browser sends requests, a server processes them and returns responses, and the browser renders the result. Understanding this flow—and the components involved—enables informed decisions about application architecture and deployment.

This section covers:

- **Client-server architecture** — How browsers and servers communicate
- **HTTP protocol** — The request-response pattern that powers the web
- **Server-side rendering** — Generating HTML dynamically with templates
- **Web servers vs application servers** — nginx for connections, application servers for code execution
- **Flask application structure** — Routes, templates, databases, and production deployment in Python

Start with [How Web Applications Work](how-web-applications-work/) for framework-agnostic concepts, then explore [Anatomy of a Flask Application](anatomy-of-a-flask-application/) for Python-specific implementation details.

{{< children />}}
