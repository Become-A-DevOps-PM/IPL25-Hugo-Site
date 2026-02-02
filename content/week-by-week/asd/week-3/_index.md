+++
title = "Week 3"
program = "IPL"
cohort = "25"
courses = ["ASD"]
description = "CI/CD and deployment: containerization, Azure infrastructure, and automated pipelines"
weight = 3
+++

# Week 3: CI/CD and Deployment

This week focuses on taking applications from local development to automated cloud deployment. You start with a standalone CI/CD pipeline tutorial, then prepare and deploy the News Flash application to Azure Container Apps with automated GitHub Actions workflows.

## Theory

*Theory content coming soon.*

## Practice

### CI/CD Pipeline Introduction

Build a complete CI/CD pipeline from scratch with a minimal Flask app:

- [Hello World CI/CD Pipeline](/exercises/application-development/hello-world-cicd-pipeline/) - Build and deploy a Hello World Flask app to Azure Container Apps with automated CI/CD using GitHub Actions

### Deployment Preparation

Prepare and deploy the News Flash application to Azure with automated CI/CD:

- [Deployment Preparation Overview](/exercises/application-development/2-deployment-preparation/) - Overview of the deployment exercise series
- [Container-Ready Configuration](/exercises/application-development/2-deployment-preparation/1-container-ready-configuration/) - Prepare the News Flash application for container deployment with environment-driven configuration, Gunicorn, and Docker
- [Provision Azure Infrastructure](/exercises/application-development/2-deployment-preparation/2-provision-azure-infrastructure/) - Create Azure resource group, container registry, Container Apps environment, Azure SQL database, and configure environment variables
- [Deploy with GitHub Actions](/exercises/application-development/2-deployment-preparation/3-deploy-with-github-actions/) - Create a GitHub Actions workflow for automated build and deploy using managed identity, OIDC federation, and az acr build
