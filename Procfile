
# Heroku launch configuration.

# Run after the new code is built but before it is run on the Dyno(s)
release: rake db:migrate

# What is run on each web Dyno.
web: bundle exec puma -C config/puma.rb

# Pre-Puma version (before we used Procfile). Kept for easy rollback if
# there are scaling issues.
#web: bin/rails server -p ${PORT:-5000} -e $RAILS_ENV