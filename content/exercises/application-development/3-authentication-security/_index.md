+++
title = "Authentication and Security"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Add user authentication, protected admin routes, and security hardening to the News Flash application"
weight = 4
+++

# Authentication and Security

Add user authentication, protected admin routes, and security hardening to the News Flash application.

## What You Will Build

This exercise series adds a complete authentication and admin system:

| Exercise | Feature |
|----------|---------|
| **Admin Blueprint** | View subscriber list in a dashboard |
| **User Model** | Secure password storage with hashing |
| **Auth Service** | Business layer for authentication |
| **Flask-Login** | Session-based login and logout |
| **Protected Routes** | Restrict admin access to logged-in users |
| **Security Headers** | OWASP-recommended hardening + CLI tools |

## Exercise Progression

The exercises build incrementally:

1. **Build first, secure later** — The admin page works unprotected initially
2. **Add user infrastructure** — User model and authentication service
3. **Enable login** — Flask-Login with session management
4. **Lock it down** — Protect routes, add security headers

## Prerequisites

Before starting, ensure you have:

- Completed the three-tier architecture exercises (2-8)
- Flask application running with subscriber persistence
- Database migrations working (`flask db upgrade`)

{{< children />}}
