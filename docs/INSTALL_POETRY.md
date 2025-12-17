# Installing Poetry on Windows

This guide provides step-by-step instructions for installing Poetry on Windows.

## Prerequisites

- Python 3.11 or higher installed
- PowerShell or Command Prompt

## Installation Methods

### Method 1: Official Installer (Recommended)

Open PowerShell and run:

```powershell
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | python -
```

This will install Poetry using the official installer script.

### Method 2: Using pip

If you prefer using pip:

```powershell
pip install poetry
```

### Method 3: Using pipx (Best for isolation)

If you have pipx installed:

```powershell
pipx install poetry
```

## Adding Poetry to PATH

After installation, you may need to add Poetry to your PATH:

### Option 1: Automatic (if using official installer)

The installer should add Poetry to your PATH automatically. You may need to:
1. Close and reopen your terminal
2. Or restart your computer

### Option 2: Manual PATH Configuration

1. Find where Poetry was installed (usually one of these):
   - `%APPDATA%\Python\Scripts`
   - `%LOCALAPPDATA%\pypoetry\Cache\pypoetry\venv\Scripts`
   - `%USERPROFILE%\.local\bin` (if using WSL/Git Bash)

2. Add to PATH:
   - Press `Win + R`, type `sysdm.cpl`, press Enter
   - Go to "Advanced" tab → "Environment Variables"
   - Under "User variables", find "Path" and click "Edit"
   - Click "New" and add the Poetry installation path
   - Click "OK" on all dialogs

### Option 3: Using PowerShell (Temporary)

For the current session only:

```powershell
$env:Path += ";$env:APPDATA\Python\Scripts"
```

## Verify Installation

Test that Poetry is installed correctly:

```powershell
poetry --version
```

You should see something like: `Poetry (version 1.x.x)`

## Troubleshooting

### "poetry: command not found"

1. **Check if Poetry is installed:**
   ```powershell
   python -m poetry --version
   ```

2. **If that works, Poetry is installed but not in PATH:**
   - Follow the PATH configuration steps above
   - Or use `python -m poetry` instead of `poetry`

3. **Reinstall if needed:**
   ```powershell
   pip uninstall poetry
   pip install poetry
   ```

### "Python not found"

Make sure Python is installed and in your PATH:
```powershell
python --version
```

If this doesn't work, reinstall Python and check "Add Python to PATH" during installation.

### Permission Errors

If you get permission errors, try:
```powershell
# Run PowerShell as Administrator
# Or use --user flag with pip
pip install --user poetry
```

## Next Steps

Once Poetry is installed:

1. Navigate to your project directory
2. Install dependencies:
   ```powershell
   poetry install
   ```
3. Activate the virtual environment:
   ```powershell
   poetry shell
   ```

## Alternative: Use pip instead

If you prefer not to use Poetry, you can use pip with the `requirements.txt` file:

```powershell
# Create virtual environment
python -m venv venv

# Activate it
.\venv\Scripts\Activate.ps1

# Install dependencies
pip install -r requirements.txt
```

## Additional Resources

- [Official Poetry Documentation](https://python-poetry.org/docs/)
- [Poetry Installation Guide](https://python-poetry.org/docs/#installation)

