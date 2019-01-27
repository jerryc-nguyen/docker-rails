FROM ruby:2.5.3-slim
LABEL author="jerryc.nguyen91@gmail.com"

# Setup environment variables that will be available to the instance
ENV APP_HOME /app
ENV RAILS_ENV production
ENV RACK_ENV production

# Installation of dependencies
RUN apt-get update -qq && apt-get install -y git-core build-essential libpq-dev nodejs && apt-get clean autoclean

# Image magic
RUN apt-get install imagemagick libmagickcore-dev libmagickwand-dev

# Cleanup installation
RUN rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Copy Gemfile
# Adding gems
COPY Gemfile Gemfile
COPY Gemfile.lock Gemfile.lock

# Bundle Gems only for production
RUN bundle install --jobs 20 --retry 5 --without development test

# Copy over our application code
COPY . $APP_HOME

# Precompile assets
RUN bundle exec rake assets:precompile

# Migrate DB
RUN bundle exec rake db:migrate

# Create sidekiq PIDS
RUN rm -rf tmp
RUN cd tmp && mkdir pids && cd pids && touch sidekiq.pid

EXPOSE 3000

# Run our app
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

