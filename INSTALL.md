# Installing Hugo for Generative AI Architecture Patterns

This guide provides detailed instructions for installing Hugo, which is required to build and run the Generative AI Architecture Patterns website locally.

## Installing Hugo (Extended Version)

The extended version of Hugo is recommended as it includes additional features like Sass/SCSS processing that may be used by the site's theme.

### macOS

#### Using Homebrew
```bash
brew install hugo
```

#### Using MacPorts
```bash
port install hugo
```

### Windows

#### Using Chocolatey
```bash
choco install hugo-extended
```

#### Using Scoop
```bash
scoop install hugo-extended
```

#### Manual Installation
1. Go to the [Hugo Releases](https://github.com/gohugoio/hugo/releases) page
2. Download the latest extended version for Windows
3. Extract the downloaded file
4. Add the extracted directory to your PATH environment variable

### Linux

#### Ubuntu/Debian
```bash
# First, install required dependencies
sudo apt update
sudo apt install wget

# Download the latest Hugo extended version
wget https://github.com/gohugoio/hugo/releases/download/v0.119.0/hugo_extended_0.119.0_linux-amd64.deb

# Install the package
sudo dpkg -i hugo_extended_0.119.0_linux-amd64.deb

# If you encounter any dependency issues
sudo apt install -f
```

#### Fedora/RHEL/CentOS
```bash
# Install from the repository
sudo dnf install hugo
```

#### Arch Linux
```bash
sudo pacman -S hugo
```

#### Manual Installation (for any Linux distribution)
```bash
# Download the latest release
wget https://github.com/gohugoio/hugo/releases/download/v0.119.0/hugo_extended_0.119.0_Linux-64bit.tar.gz

# Extract the archive
tar -xzf hugo_extended_0.119.0_Linux-64bit.tar.gz

# Move the executable to a directory in your PATH
sudo mv hugo /usr/local/bin/
```

## Verifying Installation

To verify that Hugo was installed correctly, run:
```bash
hugo version
```

You should see output that includes "hugo" and the version number.

## Next Steps

Once Hugo is installed, return to the main [README.md](README.md) to continue with the local development instructions:

1. Clone this repository
2. Run `hugo server -D` to start a local development server
3. Visit `http://localhost:1313` in your browser