hasCommand() { command -v "$1" ; }

detect_platform() {
    local OS
    local ARCH
    local PLATFORM
    
    case "$(uname -s)" in
        Darwin) OS="macos" ;;
        Linux) OS="linux" ;;
        *) OS="unknown" ;;
    esac
    
    case "$(uname -m)" in
        x86_64|amd64) ARCH="x86_64" ;;
        aarch64|arm64) ARCH="aarch64" ;;
        armv7l) ARCH="armv7" ;;
        *) ARCH="unknown" ;;
    esac
    
    PLATFORM="$OS-$ARCH"
    echo "$PLATFORM"
}

if ! hasCommand git; then
    echo "git not found -- installing git"

    if hasCommand brew; then
        brew install git
    
    elif hasCommand apt-get; then
        sudo apt-get update && sudo apt-get install -y git
    else
        echo "No package installer found"
        exit 1
    fi
fi

if ! hasCommand jq; then
    echo "jq not found -- installing jq"
    
    if hasCommand brew; then
        brew install jq
    elif hasCommand apt-get; then
        sudo apt-get update && sudo apt-get install -y jq
    elif hasCommand dnf; then
        sudo dnf install -y jq
    else
        echo "No package installer found"
        exit 1
    fi
fi

PLATFORM=$(detect_platform)
echo "Detected platform: $PLATFORM"

echo "Installing aftman"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

api="https://api.github.com/repos/LPGhatguy/aftman/releases/latest"
url=$(curl -fsSL "$api" | jq -r --arg platform "$PLATFORM" '
        .assets[] | 
        select(.name | test("aftman"; "i")) |
        select(.name | test($platform; "i")) |
        .browser_download_url' | head -n1)

if [ -z "$url" ]; then
    echo "No compatible file fonund"
    url=$(curl -fsSL "$api" | jq -r '
        .assets[] | 
        select(.name | test("aftman"; "i")) |
        .browser_download_url' | head -n1)
fi

[ -n "$url" ] || { echo "No compatible file found"; exit 1; }

fname="$tmp/$(basename "$url")"
curl -fsSL "$url" -o "$fname"

case "$fname" in
    *.tar.gz|*.tgz) 
        tar -xzf "$fname" -C "$tmp" 
        ;;
    *.zip) 
        unzip -q "$fname" -d "$tmp" 
        ;;
    *) 
        chmod +x "$fname" 
        ;;
esac

cd "$tmp"
shopt -s nullglob

arr=(aftman*)
exe="${arr[0]:-}"

if [ -z "$exe" ]; then
    exe=$(find . -maxdepth 1 -type f -name "*aftman*" | head -n1)
    exe="${exe#./}"
fi

if [ -z "$exe" ]; then
    exe=$(find . -type f -name "*aftman*" | head -n1)
    exe="${exe#./}"
fi

[ -n "$exe" ] || { echo "Couldn't find aftman.exe"; exit 1; }

if [ -f "$exe" ] && [ ! -x "$exe" ]; then
    chmod +x "$exe"
fi

echo "Setting aftman to path"
if [ -f "$exe" ]; then
    "./$exe" self-install
else
    echo "Unable to set path"
    exit 1
fi

if hasCommand aftman; then
    echo "Aftman installed successfully!"
    aftman_path=$(command -v aftman)
    echo "Aftman installed at: $aftman_path"

    aftman add rojo-rbx/rojo@7.2.1

else
    echo "aftman not install 💀"
fi

echo "Finished"
