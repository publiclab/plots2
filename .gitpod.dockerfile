FROM gitpod/workspace-mysql

# Install Redis.
RUN sudo apt-get update \
 && sudo apt-get install -y \
  redis-server \
 && sudo rm -rf /var/lib/apt/lists/

# Install Ruby version 2.7.3 and set it as default
RUN echo "rvm_gems_path=/home/gitpod/.rvm" > ~/.rvmrc
RUN bash -lc "rvm install ruby-2.7.3 && rvm use ruby-ruby-2.7.3 --default"
RUN echo "rvm_gems_path=/workspace/.rvm" > ~/.rvmrc
