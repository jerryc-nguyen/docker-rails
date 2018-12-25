FROM ruby:2.5.3
LABEL author="jerryc.nguyen91@gmail.com"

# Setup environment variables that will be available to the instance
ENV APP_HOME /app

# Installation of dependencies
RUN apt-get update -qq \
  && apt-get install -y \

    # Needed for certain gems
    build-essential \

    # Needed for postgres gem
    libpq-dev \

    # Needed for asset compilation
    nodejs \

  # The following are used to trim down the size of the image by removing unneeded data
  && apt-get clean autoclean \
  && apt-get autoremove -y \
  && rm -rf \
    /var/lib/apt \
    /var/lib/dpkg \
    /var/lib/cache \
    /var/lib/log

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
