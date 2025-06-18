# Steps to Setup ESS with Cloudflare Tunnels
## Initial Cloudflare

## ESS
1. Install helm using this guide https://helm.sh/docs/intro/install/
2. Install your favorite ingress controller with helm. I'm using nginx from this chart: https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/
3. Copy and paste the values.yaml file below to any file making sure keeping the .yaml suffix.
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
This will set the default ingress controller to whichever one you prefer with the className variable. This also disables TLS, Matrix Authentication Service, and Deployment Markers which depends on MAS in some way. If you do not want to disable MAS then use a values.yaml file like this:
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
You could also disable proxying in Cloudflare's DNS entries instead of disabling TLS within the cluster but I couldn't get the server to work when I did it that way. The issue may have been that I didn't setup any cert management. 

5. Install ess from the ess-helm github or with this command:
```
helm install ess -n ess oci://ghcr.io/element-hq/ess-helm/matrix-stack --version 25.6.1
```
You can change the first 'ess' to be whatever you want. The second 'ess' is the namespace which is used to separate different cluster resources based on the project they pertain to. You must execute ``` sudo kubectl create namespace ess ``` if you want it in the ess namespace. Alternatively, you can take out '-n ess' if you just want to install ESS in the default namespace. 
## Bridges (WIP)
1. So far I am looking into enabling app services via the values.yaml file with the appropriate configurations but if that fails I believe I can enable them via the 'additional' property.

# Final values.yaml (WIP)
This is the current configuration I am running for my server. The only difference is the 'additional' tag and everything inside of it which can be used to configure specific properties for the synapse server. 
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
  additional:
    user-config.yaml:
      config: |
        enable_registration: true
        enable_registration_without_verification: true
        report_stats: false
```
