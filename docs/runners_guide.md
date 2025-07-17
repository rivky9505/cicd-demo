# CI/CD Runners Guide

This document provides detailed information about CI/CD runner types across GitHub Actions, GitLab CI/CD, and Jenkins to help you understand their differences, advantages, and use cases.

## GitHub Actions Runners

GitHub Actions offers two main types of runners: GitHub-hosted runners and self-hosted runners.

### GitHub-Hosted Runners

GitHub-hosted runners are virtual machines maintained and upgraded by GitHub, with the GitHub Actions runner application pre-installed.

**Types of GitHub-hosted runners:**

| Runner | Operating System | Specifications | Notes |
|--------|-----------------|---------------|-------|
| `ubuntu-latest` | Ubuntu (latest LTS) | 2-core CPU, 7 GB RAM, 14 GB SSD | Most commonly used |
| `windows-latest` | Windows Server | 2-core CPU, 7 GB RAM, 14 GB SSD | Good for Windows-specific builds |
| `macos-latest` | macOS | 3-core CPU, 14 GB RAM, 14 GB SSD | Good for iOS/macOS builds |

**Advantages:**
- Zero maintenance
- Automatic updates
- Clean environment for each workflow run
- Multiple OS options

**Limitations:**
- Limited customization
- Usage limits (2,000 minutes/month for free accounts)
- Limited hardware configurations
- Limited persistence between runs

**Usage in GitHub Workflow:**

```yaml
jobs:
  build:
    runs-on: ubuntu-latest  # GitHub-hosted runner
    steps:
      - uses: actions/checkout@v2
      # Your build steps here
```

### Self-Hosted Runners

Self-hosted runners are systems you set up and manage to run GitHub Actions workflows.

**Advantages:**
- Custom hardware (CPU, RAM, disk)
- No usage limits
- Persistent tooling and dependencies
- Access to internal networks
- Special hardware support (GPUs, etc.)

**Limitations:**
- Self-maintenance required
- Security considerations
- Need to handle scaling yourself

**Setting up a self-hosted runner:**

1. Go to your GitHub repository > Settings > Actions > Runners > "New self-hosted runner"
2. Follow the instructions to download and configure the runner

**Usage in GitHub Workflow:**

```yaml
jobs:
  build:
    runs-on: self-hosted  # Use all self-hosted runners
    # Or with labels
    # runs-on: [self-hosted, linux, x64]
    steps:
      - uses: actions/checkout@v2
      # Your build steps here
```

### GitHub Actions Runner Scaling

For production environments, consider using:

1. **GitHub Actions Runner Controller (ARC)** - Kubernetes-based auto-scaling
   ```
   https://github.com/actions/actions-runner-controller
   ```

2. **Actions Runner Scaling Set** - VM-based auto-scaling
   ```
   https://github.com/philips-labs/terraform-aws-github-runner
   ```

## GitLab CI/CD Runners

GitLab CI/CD uses runners to execute jobs in your CI/CD pipeline.

### Runner Types in GitLab

GitLab offers several types of runners:

1. **Shared Runners:** Available to all projects in a GitLab instance
2. **Group Runners:** Available to all projects in a group
3. **Project-Specific Runners:** Dedicated to specific projects

### GitLab Runner Executors

GitLab runners support multiple executor types, each with different use cases:

| Executor | Description | Best for |
|----------|-------------|----------|
| **Shell** | Runs jobs on the host system | Simple setups, direct access to system |
| **Docker** | Runs each job in a clean Docker container | Isolated environments, clean builds |
| **Kubernetes** | Runs jobs as pods in a Kubernetes cluster | Dynamic scaling, cloud-native projects |
| **Docker Machine** | Creates and uses Docker hosts on demand | Auto-scaling environments |
| **VirtualBox/Parallels** | Runs jobs in virtual machines | Complete isolation, OS-level testing |
| **SSH** | Runs jobs on remote systems via SSH | Remote execution, specialized hardware |
| **Custom** | Creates a custom execution environment | Highly specialized requirements |

### Configuring GitLab Runners

To use different executors, you configure them in `.gitlab-ci.yml`:

**Shell Executor Example:**
```yaml
job:
  tags:
    - shell  # Runner with shell executor
  script:
    - echo "Running on the host system"
```

**Docker Executor Example:**
```yaml
job:
  tags:
    - docker  # Runner with Docker executor
  image: python:3.9
  script:
    - echo "Running in a Docker container"
```

**Kubernetes Executor Example:**
```yaml
job:
  tags:
    - kubernetes  # Runner with Kubernetes executor
  image: python:3.9
  script:
    - echo "Running in a Kubernetes pod"
```

### GitLab Runner Registration

To register a new GitLab Runner:

```bash
# Install GitLab Runner
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt-get install gitlab-runner

# Register the runner
sudo gitlab-runner register
# Follow prompts to provide URL, token, description, tags, and executor
```

### GitLab Auto-scaling Runners

For production environments, consider:

1. **Docker Machine executor** - VM-based auto-scaling
   ```
   https://docs.gitlab.com/runner/executors/docker_machine.html
   ```

2. **Kubernetes executor** - Pod-based auto-scaling
   ```
   https://docs.gitlab.com/runner/executors/kubernetes.html
   ```

## Jenkins Agents

Jenkins uses "agents" (formerly called "slaves") to execute build jobs. 

### Types of Jenkins Agents

1. **Permanent Agents:** Long-running dedicated machines
2. **Dynamic Agents:** Provisioned on-demand (e.g., via Docker, Kubernetes)
3. **Cloud Agents:** Provisioned in cloud environments

### Agent Controllers

| Controller Type | Description | Best for |
|----------------|-------------|----------|
| **SSH Build Agents** | Connects via SSH to remote machines | Traditional setups, existing infrastructure |
| **JNLP Build Agents** | Java Web Start agents that connect to master | Situations where the master can't initiate connections |
| **Docker Agents** | Runs builds in Docker containers | Isolated builds, clean environments |
| **Kubernetes Agents** | Uses Kubernetes to provision agent pods | Auto-scaling, cloud-native environments |
| **Amazon EC2 Agents** | Dynamically provisions EC2 instances | AWS-based infrastructure, on-demand scaling |
| **Azure VM Agents** | Dynamically provisions Azure VMs | Azure-based infrastructure |

### Jenkins Agent Configuration

**Permanent Agent Setup:**

1. Go to Jenkins > Manage Jenkins > Manage Nodes and Clouds
2. Click "New Node" and follow the setup wizard

**Docker Agent (using Jenkinsfile):**

```groovy
pipeline {
    agent {
        docker {
            image 'python:3.9-slim'
        }
    }
    
    stages {
        stage('Build') {
            steps {
                sh 'python --version'
                // Your build steps here
            }
        }
    }
}
```

**Kubernetes Agent (using Jenkinsfile):**

```groovy
pipeline {
    agent {
        kubernetes {
            yaml '''
                apiVersion: v1
                kind: Pod
                spec:
                  containers:
                  - name: python
                    image: python:3.9-slim
                    command:
                    - cat
                    tty: true
            '''
        }
    }
    
    stages {
        stage('Build') {
            steps {
                container('python') {
                    sh 'python --version'
                    // Your build steps here
                }
            }
        }
    }
}
```

### Jenkins Agent Auto-scaling

For production environments, consider:

1. **Jenkins Kubernetes Plugin** - Dynamic Kubernetes-based agents
   ```
   https://plugins.jenkins.io/kubernetes/
   ```

2. **Amazon EC2 Fleet Plugin** - Auto-scaling EC2 instances
   ```
   https://plugins.jenkins.io/ec2-fleet/
   ```

3. **Azure VM Agents Plugin** - Dynamic Azure VM agents
   ```
   https://plugins.jenkins.io/azure-vm-agents/
   ```

## Choosing the Right Runner Type

### Factors to Consider

1. **Workload Type:**
   - **Consistent workloads:** Permanent agents/runners
   - **Variable workloads:** Auto-scaling solutions

2. **Resource Requirements:**
   - **High CPU/Memory:** Dedicated hardware
   - **GPU workloads:** Specialized runners

3. **Isolation Needs:**
   - **High isolation:** Virtual machines or containers
   - **Minimal isolation:** Shell executors

4. **Cost Considerations:**
   - **Budget constraints:** Use cloud spot instances or shared runners
   - **Performance priority:** Dedicated resources

### Recommended Configurations by Project Type

| Project Type | GitHub Actions | GitLab CI/CD | Jenkins |
|-------------|---------------|-------------|---------|
| **Small web app** | GitHub-hosted (`ubuntu-latest`) | Shared runners (Docker executor) | Docker agent |
| **Large enterprise app** | Self-hosted with ARC | Project-specific runners (Kubernetes) | Kubernetes agents |
| **Mobile app** | GitHub-hosted (`macos-latest`) | Dedicated runners with macOS | macOS agent |
| **High-security project** | Self-hosted (isolated) | Self-managed runners (VM executor) | Dedicated agents |
| **AI/ML project** | Self-hosted (with GPUs) | Specific runners with GPU access | GPU-equipped agents |

## Security Considerations

1. **Runner Isolation:**
   - Container-based runners provide lightweight isolation
   - VM-based runners provide stronger isolation
   - Consider potential risks if running untrusted code

2. **Secrets Management:**
   - Store secrets in your CI/CD platform's secure storage
   - Use environment variables for sensitive data
   - Consider using secret rotation

3. **Runner Access:**
   - Limit runner access to production resources
   - Use different runners for different environments
   - Implement proper network segmentation

4. **Self-hosted Security:**
   - Keep runners updated with security patches
   - Use minimal base images/OS
   - Implement proper access controls

## Performance Optimization

1. **Caching:**
   - Implement dependency caching
   - Cache Docker layers when possible
   - Use artifacts to pass data between jobs

2. **Parallelization:**
   - Split large test suites across multiple runners
   - Run independent jobs in parallel
   - Use matrix builds for multi-environment testing

3. **Hardware Optimization:**
   - Match runner resources to job requirements
   - Consider SSD storage for I/O-intensive operations
   - Allocate sufficient memory for build operations

## Conclusion

Selecting the appropriate runner type depends on your specific project requirements, security needs, and budget constraints. All three CI/CD platforms (GitHub Actions, GitLab CI/CD, and Jenkins) offer flexible options for executing jobs, from simple cloud-hosted solutions to complex self-managed infrastructure.

For educational purposes and small projects, cloud-hosted runners often provide the best balance of convenience and features. For larger, more complex projects, consider self-hosted or auto-scaling solutions that can provide better control and cost management.
