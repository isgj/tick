FROM ruby:2.5.5
RUN apt-get update -qq && apt-get install -y postgresql-client
RUN mkdir /var/app
WORKDIR /var/app
COPY Gemfile* /var/app/
RUN gem install bundler --version 2.0.1 --force
RUN bundle install

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
