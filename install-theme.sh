#!/bin/bash
# Script to install the Hugo Book theme

# Create themes directory if it doesn't exist
mkdir -p themes

# Clone the Hugo Book theme
git clone https://github.com/alex-shpak/hugo-book themes/hugo-book

echo "Hugo Book theme installed successfully!"
echo "Run 'hugo server -D' to start the development server"