#!/bin/bash
# scripts/setup.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

# Install AWS CLI
install_aws_cli() {
    log "Installing AWS CLI..."
    
    if command -v aws &> /dev/null; then
        warning "AWS CLI is already installed."
        return 0
    fi
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        rm -rf awscliv2.zip aws/
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
        sudo installer -pkg AWSCLIV2.pkg -target /
        rm AWSCLIV2.pkg
    else
        error "Unsupported OS. Please install AWS CLI manually."
        exit 1
    fi
    
    success "AWS CLI installed successfully!"
}

# Install Docker
install_docker() {
    log "Installing Docker..."
    
    if command -v docker &> /dev/null; then
        warning "Docker is already installed."
        return 0
    fi
    
    # Detect OS
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Install Docker on Linux
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm get-docker.sh
        
        # Start Docker service
        sudo systemctl start docker
        sudo systemctl enable docker
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        warning "Please install Docker Desktop for Mac manually from https://docker.com/products/docker-desktop"
        return 0
    else
        error "Unsupported OS. Please install Docker manually."
        exit 1
    fi
    
    success "Docker installed successfully!"
}

# Install Terraform
install_terraform() {
    log "Installing Terraform..."
    
    if command -v terraform &> /dev/null; then
        warning "Terraform is already installed."
        return 0
    fi
    
    # Detect OS and architecture
    OS=""
    ARCH=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="darwin"
    else
        error "Unsupported OS. Please install Terraform manually."
        exit 1
    fi
    
    if [[ $(uname -m) == "x86_64" ]]; then
        ARCH="amd64"
    elif [[ $(uname -m) == "arm64" ]] || [[ $(uname -m) == "aarch64" ]]; then
        ARCH="arm64"
    else
        error "Unsupported architecture. Please install Terraform manually."
        exit 1
    fi
    
    # Download and install Terraform
    TERRAFORM_VERSION="1.6.0"
    wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"
    unzip "terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"
    sudo mv terraform /usr/local/bin/
    rm "terraform_${TERRAFORM_VERSION}_${OS}_${ARCH}.zip"
    
    success "Terraform installed successfully!"
}

# Install Jenkins CLI (optional)
install_jenkins_cli() {
    log "Installing Jenkins CLI..."
    
    if command -v jenkins-cli &> /dev/null; then
        warning "Jenkins CLI is already installed."
        return 0
    fi
    
    # This is optional - Jenkins CLI can be downloaded from your Jenkins instance
    warning "Jenkins CLI installation skipped. Download it from your Jenkins instance: http://your-jenkins-url/cli/"
}

# Configure AWS credentials
configure_aws() {
    log "Configuring AWS credentials..."
    
    if aws sts get-caller-identity &> /dev/null; then
        warning "AWS credentials are already configured."
        return 0
    fi
    
    echo "Please configure your AWS credentials:"
    aws configure
    
    # Verify configuration
    if aws sts get-caller-identity &> /dev/null; then
        success "AWS credentials configured successfully!"
    else
        error "Failed to configure AWS credentials."
        exit 1
    fi
}

#