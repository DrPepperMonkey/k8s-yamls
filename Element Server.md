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
  enabled: false
deploymentMarkers:
  enabled: false
matrixRTC:
  ingress:
    host: call.domain.com
serverName: domain.com
synapse:
  ingress:
    host: matrix.domain.com
```
This will set the default ingress controller to whichever one you prefer with the className variable. 
You could also disable proxying in Cloudflare's DNS entries instead of disabling TLS within the cluster but I couldn't get the server to work when I did it that way. The issue may have been that I didn't setup any cert management. 

5. Install ess from the ess-helm github
# Current challenges
1. I would like to incorporate bridges into the setup as well.
