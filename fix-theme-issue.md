# How to Fix the Missing Hugo Theme Issue

## The Problem

You're seeing this error because Hugo cannot find the "hugo-book" theme that's specified in your `config.toml` file:

```
Error: command error: failed to load modules: module "hugo-book" not found in "/Users/makyuz/GitHub/mindful-vibe/themes/hugo-book"; either add it as a Hugo Module or store it in "/Users/makyuz/GitHub/mindful-vibe/themes".: module does not exist
```

## The Solution

There are two ways to fix this issue:

### Option 1: Run the existing theme installation script

The repository already includes a script to install the theme. Simply run:

```bash
chmod +x install-theme.sh
./install-theme.sh
```

This will clone the Hugo Book theme into the themes directory.

### Option 2: Manually install the theme

If the script doesn't work for some reason, you can manually install the theme by running:

```bash
mkdir -p themes
git clone https://github.com/alex-shpak/hugo-book themes/hugo-book
```

## Verifying the Fix

After installing the theme, run the following command to start the Hugo server:

```bash
hugo server -D
```

Your site should now build and run successfully.