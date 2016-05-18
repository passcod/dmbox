FROM ruby

ENTRYPOINT ["bundle", "exec", "foreman", "start"]
WORKDIR /app
RUN gem install --no-rdoc --no-ri bundler

COPY Gemfile Gemfile.lock ./
RUN bundle

COPY . ./
