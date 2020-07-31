FROM nginx:stable

# link website from shared github repo
RUN apt-get update; apt-get --assume-yes install git
RUN cd /usr/share/nginx && \
    rm -rf html && \
    ln -s /share/github/mhk-env.github.io html
