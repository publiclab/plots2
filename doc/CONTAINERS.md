# Container setup

Docker is a system for isolating a build environment and is suitable for deploying plots2 with a predictable environment.

Plots2 requires a number of services to function. We use docker-compose to start up required services and parallel processes.

In order to configure our container we use both a configuration file and environment variables.

The configuration file is under `/containers/` directory:

    docker-compose-production.yml
    docker-compose-stable.yml
    docker-compose-testing.yml
    docker-compose-unstable.yml

Container should not include secrets (API keys, passwords, credentials). Therefore we make an `environment.sh` file which assigns the variables needed for operation.

Currently (Nov 2018) the variables in use are:

SECRET_KEY_BASE
RAILS_ENV
COMPOSE_FILE
HA_SITE_KEY
RECAPTCHA_SECRET_KEY
OAUTH_GOOGLE_APP_KEY
OAUTH_GOOGLE_APP_SECRET
OAUTH_GITHUB_APP_KEY
OAUTH_GITHUB_APP_SECRET
SERVER_ADDRESS (pop3)
USERNAME (pop3)
EMAIL_PASSWORD (pop3)
OAUTH_TWITTER_APP_KEY
OAUTH_TWITTER_APP_SECRET
OAUTH_FACEBOOK_APP_KEY
OAUTH_FACEBOOK_APP_SECRET
TWITTER_CONSUMER_KEY
TWITTER_CONSUMER_SECRET
TWITTER_ACCESS_TOKEN
TWITTER_ACCESS_TOKEN_SECRET
TWEET_SEARCH
WEBSITE_HOST_PATTERN
GMAPS_API_KEY

We use the same variables in our Jenkins staging service (but those are configured thru the GUI).

We do not keep our `environment.sh` in version control.

## Secondary configuration

`docker-compose exec` will execute commands on a **running** container. We use this in production in order to inject the IP address of the email service into the routing table of the container host (`echo 172.19.0.1 smtp >> /etc/hosts`). We have to do this in every container that needs to send mail (e.g. sidekiq, mailman and web. We also start cron this way.

So a started plots2 docker-compose is not ready for email until cron has been started, and `whenever` gem has updated the crontab.

This process has been automated in our staging and production servers by using the Makefile. Type `make deploy-container` in order to deploy a new container, and `make redeploy-container` in order to attempt to do the same with shutting down an already running container.

It is possible to run the test suite by issuing `make test-container`. Remember to set `RAILS_ENV=test` in that case.

## Running docker-compose to debug

You need to tell `docker-compose` which compose file you are using by using the `-f containers/docker-compose-...` option.

This can be avoided by setting the COMPOSE_FILE variable.

It is useful to run `docker-compose logs` to figure out when something is affecting a specific container.
