# Contributing to Speedtest Monitoring

Thank you for your interest in contributing to Speedtest Monitoring! This document provides guidelines for contributing to the project.

## How to Contribute

### Reporting Bugs

If you find a bug, please open an issue with:
- A clear title and description
- Steps to reproduce the issue
- Expected vs actual behavior
- Your environment (OS, browser, speedtest CLI version)
- Any relevant logs or screenshots

### Suggesting Enhancements

Enhancement suggestions are welcome! Please open an issue with:
- A clear title and description
- The motivation for the enhancement
- How it would benefit users
- Any implementation ideas

### Pull Requests

1. Fork the repository
2. Create a new branch (`git checkout -b feature/your-feature-name`)
3. Make your changes
4. Test your changes thoroughly
5. Commit your changes with clear messages
6. Push to your fork
7. Open a Pull Request

#### PR Guidelines

- Keep changes focused and atomic
- Update documentation if needed
- Test your changes on multiple browsers/environments if applicable
- Follow the existing code style
- Write clear commit messages

## Code Style

### Shell Scripts (cronjob.sh)
- Use 2-space indentation
- Add comments for complex logic
- Use meaningful variable names
- Include error handling

### HTML/JavaScript (index.html)
- Use 2-space indentation
- Keep code readable and well-organized
- Add comments for non-obvious functionality
- Follow Vue.js best practices

### JSON Files
- Use 2-space indentation
- Validate JSON before committing

## Testing

Before submitting a PR:
- Test the cronjob script manually
- Verify the web interface loads correctly
- Test on different browsers if possible
- Check that filtering works properly
- Ensure error handling works as expected

## Documentation

Update documentation when:
- Adding new features
- Changing configuration options
- Modifying installation steps
- Fixing significant bugs

## Questions?

Feel free to open an issue for any questions about contributing!
