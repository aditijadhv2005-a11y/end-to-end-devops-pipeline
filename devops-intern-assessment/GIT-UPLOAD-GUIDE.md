# Git and GitHub Upload Guide

This guide is separate from the application code. Run these commands in a terminal opened inside the extracted `devops-intern-assessment` folder.

## Option A: Create a new GitHub repository and push this project

1. On GitHub, create an **empty** repository. Do not initialize it with a README, license, or `.gitignore` because those files are already included here.
2. In the project folder, run:

```bash
git init
git add .
git status --short
```

3. Review the staged files. Confirm `.idea/`, `.env`, credentials, private keys, and local logs are not staged.
4. Commit and push (replace the URL with your actual repository URL):

```bash
git commit -m "Build NGINX DevOps assessment pipeline"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/YOUR_REPOSITORY.git
git push -u origin main
```

If Git asks you to authenticate, use GitHub's supported sign-in flow or a credential manager. Do not paste an access token into source files or commit it.

## Option B: The folder already has Git history

If you downloaded an archive, it should normally not contain a `.git` folder. If it does, inspect it before pushing. For an existing project cloned from your own repository, copy the files into that clone, then run:

```bash
git status --short
git add .
git diff --cached --stat
git commit -m "Complete NGINX DevOps assessment pipeline"
git push
```

## Before pushing

```bash
python3 scripts/validate-static.py
bash -n scripts/build.sh scripts/test.sh scripts/deploy.sh
git status --short
```

The `.gitignore` excludes `.idea/`, `.vscode/`, `.env` files, secrets, generated logs, and local state. Never rely only on ignore rules: review `git status` before committing.

## What happens after the push?

- GitHub Actions builds and smoke-tests the Docker image on pushes and pull requests.
- On a push to the repository's default branch, the workflow attempts to publish a SHA-tagged image to GHCR.
- The workflow does not deploy to Nomad automatically. Follow the deployment section of `README.md` after the GHCR package has been published.
