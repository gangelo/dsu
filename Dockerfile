# set /etc/docker/daemon.json to the following if you want to run this Dockerfile:
# {
#   "features": {
#     "buildkit": true
#   }
# }

# syntax=docker/dockerfile:1
# check=error=true

ARG RUBY_VERSION=3.1
FROM public.ecr.aws/docker/library/ruby:${RUBY_VERSION}

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update \
    && apt-get install --no-install-recommends \
    -y build-essential git less nano \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Configure less to not show escape sequences
ENV LESS="-R -X -F"

# Copy gem files first to leverage Docker cache
COPY Gemfile Gemfile.lock dsu.gemspec ./
COPY lib/dsu/version.rb ./lib/dsu/version.rb

# Set bundle config
ENV BUNDLE_PATH=/usr/local/bundle
RUN bundle install --jobs 4 --retry 1 \
    && rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache/ "${BUNDLE_PATH}"/ruby/*/gems/*/test/.git

# Copy the rest of the application
COPY . .

# Create non-root user and set permissions
RUN useradd dsuuser --create-home --shell /bin/bash && \
    chown -R dsuuser:dsuuser /app && \
    chown -R dsuuser:dsuuser /usr/local/bundle

# Create .bashrc with custom prompt
RUN echo 'PS1="\[\033[01;32m\]dsu>\[\033[00m\] "' >> /home/dsuuser/.bashrc

# Configure nano to not show escape sequences
# RUN echo "set nopauses" >> /home/dsuuser/.nanorc && \
#     echo "set nowrap" >> /home/dsuuser/.nanorc && \
#     echo "set nonewlines" >> /home/dsuuser/.nanorc && \
#     chown dsuuser:dsuuser /home/dsuuser/.nanorc

USER dsuuser:dsuuser

# Build and install the gem
RUN bundle exec rake install

# Add the gem's bin directory to PATH
ENV PATH="/app/bin:${PATH}"

ARG DSU_ENV=production

# Start bash with gem already installed
CMD ["/bin/bash"]
