# Steps to setup ess (so far)
1. Install helm
2. Copy and paste the hostnames.yaml file from the ess-helm repo.
3. Edit the hostnames.yaml file to have:
```
ingress:
  className: nginx
  tlsEnabled: false
elementWeb:
  ingress:
    host: chat.domain.com
matrixAuthenticationService:
  ingress:
    host: mauth.domain.com
matrixRTC:
  ingress:
    host: call.domain.com
serverName: domain.com
synapse:
  ingress:
    host: matrix.domain.com
```
This will set the default ingress controller to whichever you one you prefer with the className variable. 
From here I have tried disabling matrixAuthenticationService but it messes everything up. You could also disable proxying in Cloudflare's DNS entries but I couldn't get the server to work when I did it that way. The issue may have been that I didn't setup any cert management. 
```
synapse:
  ingress:
    host: matrix.dpmcentral.com
  workers:
    sso-login:
      enabled: false
  additional:
    user-config.yaml:
      config: |
        registration_shared_secret: "95dkH5oBdh1qfXSp"
        enable_registration: true
        enable_registration_without_verification: true
        report_stat: false
        oidc_providers: []
        authentication_providers: []
        sso:
          enabled: false
        experimental_features:
          msc3861:
          enabled: false
```
Eventually, synapse will have a configuration similar to the one above but the current problem is that enabling registration while there is 0Auth delegation still present causes an error. I am hoping once I disable all of the checks for MAS that it will resolve the 0Auth delegation.

5. Install ess from the ess-helm github
# Current challenges
1. MAS must be enabled for the server to run properly and I would like to disable it. The issue seems to be that there are some dependencies that rely on MAS in the chart so I am currently trying to find those dependencies and disable them. 
2. I would like to enable user registration without email.
3. I would like to incorporate bridges into the setup as well.
