hasCommand() { command -v "$1" ; }

if ! hasCommand git; then
    echo "git not found -- installing git"

    if hasCommand brew; then
        brew install git
    
    elif hasCommand apt-get; then
        sudo apt-get update && sudo apt-get install -y git
    elif hasCommand dnf; then
        sudo dnf install -y git
    else
        echo "No package installer found"
        exit 1
    fi
fi

echo "Installing rokit"
curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash

echo "Installing all tools"
rokit install

echo "Finished"
