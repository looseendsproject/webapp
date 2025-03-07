FROM mcr.microsoft.com/devcontainers/ruby:1-3.3-bullseye

# Default value to allow debug server to serve content over GitHub Codespace's port forwarding service
# The value is a comma-separated list of allowed domains
ENV RAILS_DEVELOPMENT_HOSTS=".githubpreview.dev,.preview.app.github.dev,.app.github.dev"

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends imagemagick postgresql-client\
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# [Optional] Uncomment this line to install additional gems.
RUN su vscode -c "gem install foreman"
# Install heroku CLI
RUN su vscode -c "curl https://cli-assets.heroku.com/install-ubuntu.sh | sh"