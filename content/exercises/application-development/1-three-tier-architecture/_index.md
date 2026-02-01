+++
title = "Three-Tier Architecture"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Build a complete Flask web application using three-tier architecture"
weight = 3
+++

# Three-Tier Architecture

This exercise series guides you through building **News Flash**, a newsletter subscription application that demonstrates proper three-tier architecture in Flask.

## What is Three-Tier Architecture?

Three-tier architecture separates an application into three distinct layers:

| Layer | Purpose | Flask Implementation |
|-------|---------|---------------------|
| **Presentation** | What users see and interact with | Routes, templates, static files |
| **Business** | Application logic and rules | Service classes, validation |
| **Data** | Storage and retrieval | Models, repositories, database |

This separation creates maintainable, testable code where each layer has a single responsibility.

## What You Will Build

By the end of these exercises, you will have a working application that:

- Displays a landing page with a call-to-action
- Collects newsletter subscriptions through a form
- Validates email addresses using business rules
- Persists subscribers to a SQLite database
- Prevents duplicate subscriptions

## Exercise Progression

The exercises build on each other, adding one layer at a time:

### Presentation Layer (Exercises 2-5)
- Project structure and application factory
- Jinja2 template inheritance
- CSS styling and interactive modals
- Form handling and user feedback

### Business Layer (Exercise 6)
- Validation service
- Data normalization
- Error handling

### Data Layer (Exercises 7-8)
- SQLAlchemy models
- Database migrations
- Repository pattern
- Full integration

## Prerequisites

Before starting, ensure you have:

- Python 3.11 or later installed
- Basic understanding of Python and HTML
- A code editor (VS Code recommended)
- Terminal access

{{< children />}}
