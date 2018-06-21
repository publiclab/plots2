# Multiparty Authentication System in Public Labs

We use Omniauth gem for OAuth2.0 at Public Labs to sign-in/log-in via different providers. OmniAuth is a library that standardizes multi-provider authentication for web applications. To enable omniauth work, we use [omniauth](https://github.com/omniauth/omniauth) gem.

Multiparty Authentication system currently has 4 providers, namely:
* Github: Github Sign In uses [omniauth-github](https://github.com/omniauth/omniauth-github) gem for OAuth.
* Google: Google Sign In uses [omniauth-google-oauth2](https://github.com/zquestz/omniauth-google-oauth2) gem for OAuth.
* Twitter: Twitter Sign In uses [omniauth-twitter](https://github.com/arunagw/omniauth-twitter) gem for OAuth.
* Facebook: Facebook Sign In uses [omniauth-facebook](https://github.com/mkdynamic/omniauth-facebook) gem for OAuth.

To sign up through/login through/link a provider, go to https://publiclab.org/auth/:provider. Sign in the provider with the desired email address and password. Then the url will be redirected to https://publiclab.org/auth/:provider/callback. Authentication hash is available in the callback. It can be accessed by ``request.env['omniauth.auth']`` for any provider. Now the user sign up, login or linking of his/her providers' accounts to the public lab's user account is based on the following cases:
1) If the client is signed in and does not have any account of the same provider through which they are trying to connect linked to his/her public lab's account, then the provider will be linked to his/her public lab account.
2) If the client is signed in and the client has an account linked to the public lab's account of the same provider through which they are trying to connect, then he is notified that linking can't be done.
3) If the client is not signed in and has the provider already linked to the public lab's account then the client log in successfully.
4) If the client is not signed in and they have an account with same email address as that given by the provider through which they are trying to connect ,then his/her existing account is linked to the provider's account. Then they are signed in to public labs.
5) If the client is not signed in and they have no account with the same email address as that given by the provider through which they are trying to sign in, then a new account is created. After a new account is created, the provider is linked to the public labs account. they are notified to change his/her password by an email.
For a new account creation, ``email_prefix`` i.e. the part of email before ``@`` symbol, is used as username. In case there exists a user with the same username then randomly generated hexadecimal code is appended to the email_prefix. Then this email_prefix is used as username.
Corresponding code is present in https://github.com/publiclab/plots2/blob/master/app/models/user.rb and https://github.com/publiclab/plots2/blob/master/app/controllers/user_sessions_controller.rb.
6) Usertags are used to store the provider and the uid for authentication. Client may delete his/her usertag via the profile page in order to delete the corresponding provider from his/her account

The functionality of this system is demonstrated on https://publiclab.org/oauth.  

## How to create app_id and app_secret?

Developers can create a developer's app for OAuth. Each app created has an app_id and an app_secret.
* For creating Facebook app go to http://developers.facebook.com/
* For creating Twitter app go to https://apps.twitter.com/app/new
* For creating Github app go to https://github.com/settings/applications/new
* For creating Google app go to https://console.developers.google.com/apis/library
And then create an app. Search for the app_id and app_secret present in your app.

## How to set up OAuth?

Add the app_id and app_secret in the Jenkins and containers/docker*.yml files in the production.
They are accessed by ENV["OAUTH_GITHUB_APP_KEY"], ENV["OAUTH_GITHUB_APP_SECRET"] etc inside the (config/initializers/omniauth.rb)[https://github.com/publiclab/plots2/blob/master/config/initializers/omniauth.rb]

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

OAuth can be tested by including the following in  [config/environments/test.rb](https://github.com/publiclab/plots2/blob/master/config/environments/test.rb)

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
