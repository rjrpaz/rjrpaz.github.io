# Use official Ruby image
FROM ruby:3.0-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock (if exists)
COPY Gemfile* ./

# Install bundler and gems
RUN gem install bundler:2.4.22
RUN bundle lock --add-platform ruby
RUN bundle lock --add-platform x86_64-linux
RUN bundle lock --add-platform aarch64-linux
RUN bundle install

# Copy the rest of the application
COPY . .

# Build the site
RUN bundle exec jekyll build

# Expose port 4000
EXPOSE 4000

# Default command
CMD ["bundle", "exec", "jekyll", "serve", "--host", "0.0.0.0", "--port", "4000", "--no-watch"]