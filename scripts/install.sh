hasCommand() { command -v "$1" ; }

echo ""
echo "This script will install all the needed tooling for development."

prompt="- Do you want to proceed with the installation? (y/n) "
echo -n "$prompt"

while true; do
    read -n 1 -s key
    
    case "$key" in
        [nN])
            echo "n"
            echo ""
            echo "Installation cancelled."
            exit 0
            ;;
        [yY])
            echo "y"
            break
            ;;
        *)
            echo -ne "\b \b"
            ;;
    esac
done

echo ""
echo "Continuing with installation..."

if ! hasCommand git; then
    echo "- Git not found -- installing git"
    
    if hasCommand brew; then
        brew install git
    elif hasCommand apt-get; then
        sudo apt-get update && sudo apt-get install -y git
    elif hasCommand dnf; then
        sudo dnf install -y git
    else
        echo "- No supported package manager found."
        exit 1
    fi
    
    echo "- Git installed successfully."
    echo ""
else
    echo "- Git is installed."
    echo ""
fi
hasRokit=$(hasCommand rokit)

if $hasRokit then
    echo "- Rokit is installed."
else
    echo "- Rokit not found -- installing rokit"
    curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
    echo "- Rokit installed successfully."
fi

echo "- Installing all tools with rokit."
rokit install

echo ""
echo "Installation complete! You can now develop with our tools."