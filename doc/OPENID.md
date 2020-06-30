# OpenID on PublicLab.org

We use PublicLab.org as an OpenID provider for two other sites run by Public Lab - [SpectralWorkbench.org](https://spectralworkbench.org) (SWB) and [MapKnitter.org](https://mapknitter.org) (MK). Source code for those can be found here:

* https://github.com/publiclab/mapknitter/
* https://github.com/publiclab/spectral-workbench/

This enables:

* a "single sign-on" across several Public Lab systems
* no need to store private data like encrypted passwords in MK or SWB

However, MK and SWB are customized to **only** use PublicLab.org as an OpenId provider. This dates back to a time when OpenId was more widely used, and we'd probably use OAuth today given the choice.

## Code

Code for the OpenId provider can be found at:

* Controller: https://github.com/publiclab/plots2/blob/main/app/controllers/openid_controller.rb
* Routes: https://github.com/publiclab/plots2/blob/cac725748bbcb2a1cadf025e16f3aca5baf6a750/config/routes.rb#L58-L76

## Testing

Testing can be difficult, but can be done by cloning a local copy of both SpectralWorkbench AND PublicLab.org/`plots2`.

You first change the OpenId address on the local clone of SWB -- at `app/controllers/sessions_controller.rb:  

```
@@openid_url_base  = "https://publiclab.org/people/"
```

(on this line: https://github.com/publiclab/spectral-workbench/blob/7160bea20dfd6a7ce4da9573eed5e456dc3a9490/app/controllers/sessions_controller.rb#L5)

...to be instead: `http://localhost:3000/people/`

Then start SWB on port 3001 with the command `passenger start -p 3001`

At the same time, have PublicLab.org/`plots2` running on port 3000, with the normal `passenger start` command

Then, go to http://localhost:3000/login and try to log in -- using an account on your local copy of PublicLab.org/`plots2`

You should be redirected to your local PublicLab.org/`plots2` instance, and asked to approve the login. 

However, you may be directed back to SpectralWorkbench.org instead of http://localhost:3001 -- please update this documentation if so -- but you should be able to confirm that you were able to log in in any case.

Further work on building tests around these functions is ongoing at:

https://github.com/publiclab/plots2/issues/2813
