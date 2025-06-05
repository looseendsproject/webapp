FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bookworm

ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# Install OS packages
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

# Make chromium accessible to tools expecting 'google-chrome'
RUN ln -sf /usr/bin/chromium /usr/bin/google-chrome

# Install foreman gem
RUN su vscode -c "gem install foreman"

# Install Heroku CLI
RUN su vscode -c "curl https://cli-assets.heroku.com/install-ubuntu.sh | sh"

# Environment variable for some test runners
ENV CHROME_BIN=/usr/bin/chromium
