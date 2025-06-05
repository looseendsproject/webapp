FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# Install required OS packages, including Chromium & Chromedriver for Selenium tests
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        imagemagick \
        postgresql-client \
        chromium \
        chromium-driver \
        fonts-liberation \
        libnss3 \
        libxss1 \
        libasound2 \
        libx11-xcb1 \
        xauth \
        x11-utils \
        xvfb \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create a symlink from 'chromium' to 'google-chrome' to satisfy tools expecting Chrome binary
RUN ln -sf /usr/bin/chromium /usr/bin/google-chrome

# Install foreman gem (run as vscode user)
RUN su vscode -c "gem install foreman"

# Install Heroku CLI (run as vscode user)
RUN su vscode -c "curl https://cli-assets.heroku.com/install-ubuntu.sh | sh"

# Set environment variable for Chrome binary path (used by some test tools)
ENV CHROME_BIN=/usr/bin/chromium
