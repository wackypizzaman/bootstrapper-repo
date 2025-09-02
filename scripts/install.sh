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

# Check for rokit and aftman
hasRokit=false
hasAftman=false
useRokit=true

if hasCommand rokit; then
    hasRokit=true
fi

if hasCommand aftman; then
    hasAftman=true
fi

if $hasRokit && ! $hasAftman; then
    echo "- Rokit is installed."
elif ! $hasRokit && $hasAftman; then
    echo "- Aftman is installed."
    useRokit=false
elif $hasRokit && $hasAftman; then
    echo "- Both Rokit and Aftman are installed."
else
    echo "- Rokit and aftman not found -- installing rokit"
    curl -sSf https://raw.githubusercontent.com/rojo-rbx/rokit/main/scripts/install.sh | bash
    echo "- Rokit installed successfully."
fi

if $useRokit; then
    echo "- Installing all tools with rokit."
    rokit install
else
    echo "- Installing all tools with aftman."
    aftman install
fi

echo ""
echo "Installation complete! You can now develop with our tools."