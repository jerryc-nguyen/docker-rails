FROM ruby:2.5.3-slim
LABEL author="jerryc.nguyen91@gmail.com"

ARG DATABASE_URL

# Setup environment variables that will be available to the instance
ENV APP_HOME /my_app_production
ENV RAILS_ENV production
ENV RACK_ENV production
ENV DATABASE_URL "${DATABASE_URL}"

# Installation of dependencies
RUN apt-get update -qq && apt-get install -y git-core build-essential libpq-dev nodejs && apt-get clean autoclean && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy Gemfile
# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Bundle Gems
RUN bundle install --jobs 20 --retry 5 --without development test

# Copy over our application code
COPY . $APP_HOME

# Precompile assets
RUN bundle exec rake assets:precompile

# Migrate DB
RUN bundle exec rake db:migrate

EXPOSE 3000

# Run our app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
