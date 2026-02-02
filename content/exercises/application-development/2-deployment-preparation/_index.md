+++
title = "Deployment Preparation"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "Prepare and deploy the News Flash application to Azure Container Apps with Azure SQL Database and automated CI/CD"
weight = 4
+++

# Deployment Preparation

Prepare and deploy the News Flash application to Azure Container Apps with Azure SQL Database and automated CI/CD. Students go from creating deployment files to provisioning Azure infrastructure to pushing code and having CI/CD deploy automatically.

## What You Will Learn

This suite takes your application from local development to automated cloud deployment:

| Concept | Purpose |
|---------|---------|
| **Environment-driven config** | Same code runs locally (SQLite) and in Azure (Azure SQL) |
| **Gunicorn + Dockerfile** | Production WSGI server packaged as a container image |
| **Azure infrastructure** | Resource group, container registry, Container Apps, Azure SQL, env vars |
| **12-Factor App** | Configuration via environment variables, not code |
| **GitHub Actions CI/CD** | Automated build and deploy on every push to main |
| **OIDC federation** | Passwordless authentication between GitHub and Azure |

## Exercises

| Exercise | Focus |
|----------|-------|
| **Container-Ready Configuration** | Dockerfile, Gunicorn entry point, environment-driven config |
| **Provision Azure Infrastructure** | Resource group, ACR, Container Apps, Azure SQL, env vars |
| **Deploy with GitHub Actions** | Managed identity, OIDC, automated build/deploy pipeline |

## Prerequisites

Before starting, ensure you have:

- Completed the three-tier architecture exercises
- Flask application running locally with `flask run`
- Docker installed on your development machine (recommended but optional)
- Azure CLI installed (`az login`)
- GitHub repository for your application

{{< children />}}
