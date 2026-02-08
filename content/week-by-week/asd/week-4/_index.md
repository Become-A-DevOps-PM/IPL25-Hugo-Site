+++
title = "Week 4"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Authentication and security: user login, protected routes, security hardening, and production deployment"
weight = 4
+++

# Week 4: Authentication and Security

This week focuses on adding user authentication, protected admin routes, and security hardening to the News Flash application. You will also deploy the complete authentication system to production on Azure.

## Theory

- [Repetition — Agil Mjukvaruutveckling och Driftsättning](/presentations/repetition-asd.html) - Review of key course concepts ahead of the assignment

## Practice

### Authentication and Security

Add a complete authentication and admin system to the News Flash application:

- [Authentication and Security Overview](/exercises/application-development/3-authentication-security/) - Overview of the authentication exercise series
- [Admin Blueprint and Subscriber Dashboard](/exercises/application-development/3-authentication-security/1-admin-blueprint-and-subscriber-dashboard/) - Build an admin page with a subscriber dashboard
- [User Model and Password Hashing](/exercises/application-development/3-authentication-security/2-user-model-and-password-hashing/) - Create a user model with secure password storage
- [Authentication Service](/exercises/application-development/3-authentication-security/3-authentication-service/) - Build the business logic layer for authentication
- [Flask-Login and Login Routes](/exercises/application-development/3-authentication-security/4-flask-login-and-login-routes/) - Add session-based login and logout with Flask-Login
- [Protecting Admin Routes](/exercises/application-development/3-authentication-security/5-protecting-admin-routes/) - Restrict admin access to authenticated users only
- [Security Headers and Admin CLI](/exercises/application-development/3-authentication-security/6-security-headers-and-admin-cli/) - Add OWASP-recommended security headers and CLI tools
- [Deploy Authentication to Production](/exercises/application-development/3-authentication-security/7-deploy-authentication-to-production/) - Deploy the authentication system to Azure with admin seeding
