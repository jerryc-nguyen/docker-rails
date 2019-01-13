FROM ruby:2.5.3-slim
LABEL author="jerryc.nguyen91@gmail.com"

# Setup environment variables that will be available to the instance
ENV APP_HOME /my_app_development

# Installation of dependencies
RUN apt-get update -qq && apt-get install -y git-core build-essential libpq-dev nodejs && apt-get clean autoclean && rm -rf /var/lib/apt /var/lib/dpkg /var/lib/cache /var/lib/log

# Create a directory for our application
# and set it as the working directory
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Add our Gemfile
# and install gems
ADD Gemfile* $APP_HOME/
RUN bundle install

# Copy over our application code
ADD . $APP_HOME/

EXPOSE 3000

# Run our app
CMD bundle exec rails s -p 3000 -b '0.0.0.0'
