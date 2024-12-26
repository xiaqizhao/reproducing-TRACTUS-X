#!/bin/zsh

# Step 1: Set up the workspace directory and environment
clear

# Create the workspace directory if it doesn't exist
mkdir -p ~/workspace4TRACTUS
cd ~/workspace4TRACTUS

# Step 2: Install Go
# Check if Go is already installed
if ! command -v go &>/dev/null; then
    # Go is not installed, start the installation process
    echo "Go is not installed, starting installation..."

    # Download the Go installation package
    wget https://go.dev/dl/go1.23.3.linux-amd64.tar.gz

    # Extract the Go installation package to /usr/local
    sudo tar -C /usr/local -xzf go1.23.3.linux-amd64.tar.gz

    # Set Go environment variables
    echo "export PATH=\$PATH:/usr/local/go/bin" | sudo tee -a /etc/profile >/dev/null

    # Apply the environment variables (for all users, using /etc/profile)
    source /etc/profile

    # Verify if Go installation was successful
    go version
else
    # Go is already installed, print the current version
    echo "Go is installed, current version is: $(go version)"
fi

# Step 3: Install Docker
# Check if Docker is already installed
if ! command -v docker &>/dev/null; then
    echo "Docker is not installed, starting installation..."

    # Update the apt package index
    sudo apt update

    # Install necessary dependencies
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

    # Set up the Docker repository
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"

    # Update the apt package index again
    sudo apt update

    # Install Docker CE (Community Edition)
    sudo apt install -y docker-ce

    # Start the Docker service and enable it to start on boot
    sudo systemctl start docker
    sudo systemctl enable docker

    # Verify if Docker installation was successful
    docker --version
else
    # Docker is already installed, print the current version
    echo "Docker is installed, current version is: $(docker --version)"
fi

# Step 4: Install kind
# Reference: https://kind.sigs.k8s.io/docs/user/quick-start/#installation
# Check if kind is already installed
if ! command -v kind &>/dev/null; then
    if [ $(uname -m) = x86_64 ]; then
        curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
        chmod +x ./kind
        sudo mv ./kind /usr/local/bin/kind

        # Install kind using Go and create a cluster
        go install sigs.k8s.io/kind@v0.25.0 && kind create cluster
    fi
else
    # kind is already installed, print the current version
    echo "kind is installed, current version is: $(kind version)"
fi

# Step 5: Prerequisites for Installing Terraform

# Ensure that the system is up to date and the required packages are installed
# Initialize an empty list of package names
missing_packages=()

# Function to check if a package is installed and add it to the missing_packages list if not
check_and_add_package() {
    package_name=$1
    if ! dpkg -l | grep -q "$package_name"; then
        missing_packages+=("$package_name")
        echo "$package_name is not installed, preparing to install..."
    fi
}

# Check if gnupg, software-properties-common, and curl are installed
check_and_add_package "gnupg"
check_and_add_package "software-properties-common"
check_and_add_package "curl"

# If there are any missing packages, install them all at once
if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "Installing missing dependencies: ${missing_packages[@]}"
    sudo apt update
    sudo apt install -y "${missing_packages[@]}"
else
    echo "All necessary packages are already installed"
fi

# Step 6: Install HashiCorp GPG key and repository
# Reference: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

# Check if the HashiCorp GPG key is already present
if ! [ -f /usr/share/keyrings/hashicorp-archive-keyring.gpg ]; then
    echo "Installing HashiCorp GPG key and setting up repository..."

    # Download and import the HashiCorp GPG key
    wget -O- https://apt.releases.hashicorp.com/gpg |
        gpg --dearmor |
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg >/dev/null

    # Verify the GPG key fingerprint
    gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint

    # Add the HashiCorp repository to the system sources list
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" |
        sudo tee /etc/apt/sources.list.d/hashicorp.list

    # Update the apt package index
    sudo apt update
else
    echo "HashiCorp GPG key and repository already exist, skipping installation steps"
fi

# Step 7: Enable tab completion for Terraform commands.
# Check if Terraform is already installed
if ! command -v terraform &>/dev/null; then
    echo "Installing Terraform..."
    sudo apt-get install -y terraform

    # Enable Terraform command auto-completion
    if [ ! -f "$HOME/.zshrc" ]; then
        touch "$HOME/.zshrc"
        echo "$HOME/.zshrc file has been created"
    fi
    terraform -install-autocomplete
else
    echo "Terraform is already installed, skipping installation"
fi

# Step 8: Install kubectl (if not installed)
# Reference: https://kubernetes.io/docs/tasks/tools/install-kubectl/

if ! command -v kubectl &>/dev/null; then
    echo "kubectl is not installed, starting installation..."
    
    # Download the latest stable version of kubectl
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    # Make kubectl executable
    chmod +x kubectl
    
    # Move kubectl to /usr/local/bin
    sudo mv kubectl /usr/local/bin/
    
    # Verify the installation
    kubectl version --client
else
    echo "kubectl is already installed, current version is: $(kubectl version --client --short)"
fi

########################
# Step 9: Check if Java is installed
if ! command -v java &> /dev/null
then
    echo "Java is not installed, installing Java..."

    # Define download link
    JAVA_URL="https://download.oracle.com/java/17/archive/jdk-17.0.12_linux-x64_bin.deb"
    JAVA_DEB="jdk-17.0.12_linux-x64_bin.deb"

    # Update package index
    sudo apt update

    # Install necessary dependencies
    sudo apt install -y wget dpkg

    # Download the .deb file for JDK 17
    echo "Downloading JDK 17..."
    wget $JAVA_URL -O $JAVA_DEB

    # Install the .deb file
    echo "Installing JDK 17..."
    sudo dpkg -i $JAVA_DEB

    # Resolve any dependency issues
    echo "Resolving dependencies..."
    sudo apt-get install -f

    # Set JAVA_HOME environment variable
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    echo "Setting JAVA_HOME to: $JAVA_HOME"

    # Add JAVA_HOME to the .zshrc configuration file
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.zshrc
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> ~/.zshrc

    # Apply changes immediately
    source ~/.zshrc

    # Verify Java installation
    java -version

    echo "Java installation completed and JAVA_HOME has been set."
else
    echo "Java is already installed, skipping installation process."
fi

echo "Installation complete! Please log out of the current zsh session."