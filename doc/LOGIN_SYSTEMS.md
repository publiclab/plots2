# Multiparty Authentication System in Public Lab

We use Omniauth gem for OAuth2.0 at Public Lab to sign up/log in via different providers. OmniAuth is a library that standardizes multi-provider authentication for web applications. To enable omniauth work, we use [omniauth](https://github.com/omniauth/omniauth) gem.

Multiparty Authentication system currently has 4 providers, namely:
* Github: Using the [omniauth-github](https://github.com/omniauth/omniauth-github) gem for OAuth.
* Google: Using the [omniauth-google-oauth2](https://github.com/zquestz/omniauth-google-oauth2) gem for OAuth.
* Twitter: Using the [omniauth-twitter](https://github.com/arunagw/omniauth-twitter) gem for OAuth.
* Facebook: Using the [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook) gem for OAuth.

To sign up or log in via a provider or to link a provider, go to https://publiclab.org/auth/:provider. Sign in through the provider with the desired email address and password. Then the user will be redirected to https://publiclab.org/auth/:provider/callback. Authentication hash is available in the callback. It can be accessed by `request.env['omniauth.auth']` for any provider. Now the user signs up, logs in or links their providers' accounts to their Public Lab account.

Linking of any account through providers is based on the following cases:
1) If the client is signed in and does not have any account of the same provider through which they are trying to connect to their Public Lab account, then the provider will be linked to their account.
2) If the client is signed in and has an account linked to their Public Lab account of the same provider through which they are trying to connect, then he/she is notified that the linking can't be done.
3) If the client is not signed in and has the provider already linked to their Public Lab account, then the client logs in successfully.
4) If the client is not signed in and has an account with same email address as that given by the provider through which they are trying to connect, then their existing account is linked to the provider's account and they're signed in to Public Lab.
5) If the client is not signed in and has no account with the same email address as that given by the provider through which they are trying to sign in, then a new account is created. After a new account is created, the provider is linked to that new Public Lab account and the client is notified by email to change their password.

For a new account creation, `email_prefix` i.e. the part of email before `@` symbol, is used as username. In case there exists a user with the same username then randomly generated hexadecimal code is appended to the email_prefix. Then this email_prefix is used as username.
Corresponding code is present in https://github.com/publiclab/plots2/blob/main/app/models/user.rb and https://github.com/publiclab/plots2/blob/main/app/controllers/user_sessions_controller.rb.

6) Usertags are used to store the provider and the uid for authentication. The client may delete their usertag via the profile page in order to delete the corresponding provider from their account.

The functionality of this system is demonstrated on https://publiclab.org/oauth.  

## How to create app_id and app_secret?

Developers can create a developer's app for OAuth. Each app created has an app_id and an app_secret.
* For creating Facebook app go to http://developers.facebook.com/
* For creating Twitter app go to https://apps.twitter.com/app/new
* For creating Github app go to https://github.com/settings/applications/new
* For creating Google app go to https://console.developers.google.com/apis/library
And then create an app. Search for the app_id and app_secret present in your app.

## How to set up client id and client secret in development mode?

As to the environment variables, you can insert them at run time locally by doing:

```
OAUTH_GOOGLE_APP_KEY=xxxxxxxx passenger start
```

Or, you can put it in a file like `environment.sh` which is like:

```
OAUTH_GOOGLE_APP_KEY=xxxxxxxx
```

and do:

```
source environment.sh && passenger start
```

Or, write them in config/application.yml file

## How to set up OAuth?

Add the app_id and app_secret in the Jenkins and containers/docker*.yml files in the production.
They are accessed by ENV["OAUTH_GITHUB_APP_KEY"], ENV["OAUTH_GITHUB_APP_SECRET"] etc inside the (config/initializers/omniauth.rb)[https://github.com/publiclab/plots2/blob/main/config/initializers/omniauth.rb]

## How to setup login modal on various locations?

For improving UI, login and signup modals were created. The code for the login and signup modals is https://github.com/publiclab/plots2/blob/main/app/views/layouts/_header.html.erb#L176-L266.

A custom JavaScript class named 'requireLogin' is inserted at the locations where login modal needs to be rendered.

For example, it can be implemented in a button with the button class as `btn btn-default requireLogin`.

There is also a JavaScript function called `require_login_and_redirect_to(url)` which will do exactly that, if you pass it a URL. The url can include GET parameters so it can be used to login and then redirect to, for example, a prepopulated post form at `/post?title=My Title&body=Hello`.

See more [on this line](https://github.com/publiclab/plots2/blob/e190eae1ce7bf215b99b6efe7f828e17deb3213e/app/views/user_sessions/_form.html.erb#L83)

## Variables used

* OAUTH_GOOGLE_APP_KEY: It contains app_id of the google developer's app created
* OAUTH_GOOGLE_APP_SECRET: It contains app_secret of the google developer's app created
* OAUTH_GITHUB_APP_KEY: It contains app_id of the github developer's app created
* OAUTH_GITHUB_APP_SECRET: It contains app_secret of the github developer's app created
* OAUTH_FACEBOOK_APP_KEY: It contains app_id of the facebook developer's app created
* OAUTH_FACEBOOK_APP_SECRET: It contains app_secret of the facebook developer's app created
* OAUTH_TWITTER_APP_KEY: It contains app_id of the twitter developer's app created
* OAUTH_TWITTER_APP_SECRET: It contains app_secret of the twitter developer's app created

## Testing

OAuth can be tested by including the following in  [config/environments/test.rb](https://github.com/publiclab/plots2/blob/main/config/environments/test.rb)

```
OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:provider] = OmniAuth::AuthHash.new({
    'provider' => 'name_of_provider',
    'uid' => '1357908642',
    'info' => {
      'name' => 'user name',
      'email' => 'user.email.address@xyz.com'
    }
})
```
This is a way of storing the hash returned by the OAuth service.
Tester can then use these values by
``request.env['omniauth.auth'] =  OmniAuth.config.mock_auth[:google_oauth2_2]``

## Notifications

Let us define the password_checker field for authentication system
A user creates an account by the legacy authentication system 0
Facebook 1
Github 2
Google 3
Twitter 4

Password is set up by the client is denoted by zero. Password not set up is denoted by non zero field.
If a user who is not having password field set up tries to log in with password and username then they will be noticed with an error message to reset their password.
Upon setting up password, password_checker field is set to zero. 
