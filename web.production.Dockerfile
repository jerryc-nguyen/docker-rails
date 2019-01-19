FROM ruby:2.5.3-slim
LABEL author="jerryc.nguyen91@gmail.com"

ARG DATABASE_URL
ARG SECRET_KEY_BASE=78b372a0ed9ef83ec5e1686485df723a3db60ed56fd4654e2b2c11bf9953cb410ab82a4a618e4a27a9eb01340da960ccedb8d52f438c653268146e8e9db669b2

# Setup environment variables that will be available to the instance
ENV APP_HOME /my_app_production
ENV RAILS_ENV production
ENV RACK_ENV production
ENV DATABASE_URL "${DATABASE_URL}"
ENV SECRET_KEY_BASE "${SECRET_KEY_BASE}"

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

EXPOSE 3000

# Run our app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
