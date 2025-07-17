# CI/CD Workshop Guide for Graduate Students

## Introduction

This document provides step-by-step instructions for setting up and using this CI/CD demonstration project. It is designed for graduate-level computer science students to understand CI/CD concepts across GitHub, GitLab, and Jenkins.

## Workshop Timeline (4 hours)

1. **Introduction to CI/CD Concepts** (30 minutes)
   - CI/CD principles
   - Benefits and challenges
   - Common tools and patterns

2. **Project Overview** (15 minutes)
   - Application architecture
   - Project structure
   - Expected outcomes

3. **Environment Setup** (30 minutes)
   - Setting up Git repositories
   - Local development environment
   - Access to CI/CD platforms

4. **Hands-on: GitHub Actions** (45 minutes)
   - GitHub Actions concepts
   - Workflow configuration
   - Running the pipeline

5. **Hands-on: GitLab CI/CD** (45 minutes)
   - GitLab CI/CD concepts
   - Pipeline configuration
   - Running the pipeline

6. **Hands-on: Jenkins** (45 minutes)
   - Jenkins concepts
   - Pipeline configuration
   - Running the pipeline

7. **Container Registry Options** (15 minutes)
   - Public vs. private registries
   - Authentication methods
   - Security considerations

8. **Advanced Deployment Strategies** (30 minutes)
   - Blue/Green deployments
   - Canary releases
   - Feature flags

9. **Q&A and Wrap-up** (15 minutes)

## Setup Instructions for Students

### GitHub Actions Setup

1. Create a GitHub account if you don't have one
2. Fork the project repository
3. Enable GitHub Actions in your fork
4. Set up secrets:
   - Navigate to Settings > Secrets
   - Add the necessary secrets (KUBECONFIG, etc.)
5. Make a small change to the code and push to trigger the workflow
6. Examine the workflow run in the Actions tab

### GitLab CI/CD Setup

1. Create a GitLab account if you don't have one
2. Import the project repository
3. Set up CI/CD variables:
   - Navigate to Settings > CI/CD > Variables
   - Add the necessary variables (CI_REGISTRY, CI_REGISTRY_USER, etc.)
4. Make a small change to the code and push to trigger the pipeline
5. Examine the pipeline run in the CI/CD > Pipelines section

### Jenkins Setup

1. Set up Jenkins (instructor may provide a shared instance)
2. Create a new Pipeline job
3. Configure the pipeline to use the Git repository
4. Add necessary credentials in Jenkins credential store
5. Run the pipeline and examine the results

## Container Registry Options

### Public Registries
- **Docker Hub**: Free for public images, limited free private images
- **GitHub Container Registry (ghcr.io)**: Free for public repositories
- **Quay.io**: Free for public repositories

### Private Registries
- **Self-hosted Docker Registry**: Full control, requires maintenance
- **AWS ECR**: Integrated with AWS services
- **Azure Container Registry**: Integrated with Azure services
- **Google Container Registry**: Integrated with Google Cloud services

### Registry Authentication Recommendations

For this educational project, we recommend:

1. **GitHub Actions**: Use GitHub Container Registry (ghcr.io) with automatic GITHUB_TOKEN authentication
2. **GitLab CI/CD**: Use GitLab's built-in Container Registry
3. **Jenkins**: Use any registry with credential-based authentication

## CI/CD Runner Types

### GitHub Actions Runners

1. **GitHub-hosted runners**:
   - Pros: No maintenance, multiple environments available
   - Cons: Limited minutes for private repos, less control

2. **Self-hosted runners**:
   - Pros: Unlimited minutes, custom environment, more control
   - Cons: Requires maintenance, security considerations

### GitLab Runners

1. **Shared runners**:
   - Pros: No setup required, available immediately
   - Cons: Limited resources, potential queue time

2. **Specific runners**:
   - Pros: Dedicated resources, custom environments
   - Cons: Requires setup and maintenance

3. **Executor types**:
   - Docker: Isolated, clean environment each run
   - Shell: Direct access to host, better for specific host dependencies
   - Kubernetes: Dynamic scaling, isolated environments

### Jenkins Agents

1. **Permanent agents**:
   - Pros: Always available, fully customizable
   - Cons: Resource inefficient, maintenance overhead

2. **Cloud agents**:
   - Pros: Dynamic scaling, cost-efficient
   - Cons: More complex setup

3. **Kubernetes agents**:
   - Pros: Highly scalable, isolated environments
   - Cons: Requires Kubernetes knowledge

## Deployment Best Practices

1. **Use declarative configurations**:
   - Store deployment manifests in version control
   - Use templates for environment-specific values

2. **Implement progressive delivery**:
   - Consider blue/green or canary deployments
   - Use feature flags for safer releases

3. **Automate rollbacks**:
   - Have a strategy for quick recovery
   - Test rollback procedures regularly

4. **Monitor deployments**:
   - Track deployment success/failure metrics
   - Set up alerts for deployment issues

## Workshop Exercises

### Basic Exercises
1. Make a code change and observe the pipeline execution
2. Add a new API endpoint and update tests
3. Modify the Dockerfile to improve build efficiency

### Intermediate Exercises
1. Add a linting step to the pipelines
2. Implement caching to speed up builds
3. Add a manual approval step for production deployments

### Advanced Exercises
1. Implement a blue/green deployment strategy
2. Set up security scanning for the Docker image
3. Add end-to-end tests to the pipeline

## Resources for Further Learning

- Books:
  - "Continuous Delivery" by Jez Humble and David Farley
  - "DevOps Handbook" by Gene Kim et al.
  - "Docker Deep Dive" by Nigel Poulton

- Online Courses:
  - GitHub Actions on GitHub Learning Lab
  - GitLab CI/CD on GitLab Learn
  - Jenkins Fundamentals on CloudBees University

- Documentation:
  - [GitHub Actions](https://docs.github.com/en/actions)
  - [GitLab CI/CD](https://docs.gitlab.com/ee/ci/)
  - [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)

## Conclusion

This CI/CD demonstration project provides hands-on experience with three popular CI/CD platforms. By working through this project, students will gain practical knowledge of CI/CD principles and practices that are directly applicable to industry settings.
