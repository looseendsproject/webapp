FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# Install required OS packages, including Chromium & Chromedriver for Selenium tests
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        chromium \
        chromium-driver \
        direnv \
        fonts-liberation \
        imagemagick \
        libasound2 \
        libnss3 \
        libx11-xcb1 \
        libxss1 \
        postgresql-client \
        x11-utils \
        xauth \
        xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a symlink from 'chromium' to 'google-chrome' to satisfy tools expecting Chrome binary
RUN ln -sf /usr/bin/chromium /usr/bin/google-chrome

# Set environment variable for Chrome binary path (used by some test tools)
ENV CHROME_BIN=/usr/bin/chromium

# Install foreman gem (run as vscode user)
RUN su vscode -c "gem install foreman"

# Install Heroku CLI (run as vscode user)
# Do this last as if it fails it will not break the devcontainer build
RUN su vscode -c "curl https://cli-assets.heroku.com/install-ubuntu.sh | sh"