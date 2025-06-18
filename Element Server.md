# Steps to Setup ESS with Cloudflare Tunnels
All of this is completely free except the domain so if you can't find the free option look a little harder.
## Initial Cloudflare
1. Acquire a domain from your favorite domain broker (This is the money part.)
2. Change the nameservers to point to cloudflare.
3. Open cloudflare and go to 'Zero Trust' on the left.
4. Do the initial setup stuff. It will ask for a payment method but it is still free.
5. Click the 'Networks' dropdown on the left and then click 'Tunnels'.
6. Click 'Create Tunnel' at the top and choose 'Cloudflared'.
7. Name the tunnel whatever you want and click next.
8. I'm using docker compose for this setup but you choose whichever option you prefer. Click on the 'Docker' option towards the top.
9. At this point, if you do not have docker compose install it. On ubuntu that looks like ```sudo apt install docker-compose -y ```.
10. Create a new folder called 'cloudflared'. on ubuntu that looks like ```sudo mkdir cloudflared ```.
11. Copy and paste this into a yaml file
```
services:
  tunnel:
    image: cloudflare/cloudflared:latest
    container_name: cloudflared
    restart: unless-stopped
    command: tunnel run
    environment:
      - TUNNEL_TOKEN=yourtoken
```
12. Where it says tunnel token copy and past the command that Cloudflare gives you but leave out everything before '--token' and paste that in place of 'yourtoken'
13. while still in the cloudflared folder run the command on ubuntu ```sudo docker-compose up -d ``` to start the service and run it in the background.

## ESS
1. Install helm using this guide https://helm.sh/docs/intro/install/
2. Install your favorite ingress controller with helm. I'm using nginx from this chart: https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-helm/
3. Copy and paste the values.yaml file below to any file making sure keeping the .yaml suffix and changing 'domain' to be the domain you purchased.
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

5. Install ESS from the ess-helm github or with this command:
```
helm install ess -n ess oci://ghcr.io/element-hq/ess-helm/matrix-stack --version 25.6.1
```
You can change the first 'ess' to be whatever you want. The second 'ess' is the namespace which is used to separate different cluster resources based on the project they pertain to. You must execute ``` sudo kubectl create namespace ess ``` if you want it in the ess namespace. Alternatively, you can take out '-n ess' if you just want to install ESS in the default namespace. 
6. HAProxy within the cluster has some issues with this setup which I haven't diagnosed. You potentially do not need it at all but for now there is a fix that needs to be done. with the command ```sudo KUBE_EDITOR=nano kubectl edit ingress ess-synapse -n ess ``` change 
```
          service:
            name: ess-synapse
            port:
              name: some HAProxy thing
        path: /
        pathType: Prefix
      - backend:
          service:
            name: ess-synapse
            port:
              name: some HAProxy thing
```
to
```
          service:
            name: ess-synapse
            port:
              number: 8008
        path: /
        pathType: Prefix
      - backend:
          service:
            name: ess-synapse
            port:
              number: 8009
```
I changed the HAProxy routing to instead be a specific port for the service and I also changed the path to be '/' instead of the stuff they had there I don't remember exactly what was in the path but I do remember making it blank. I'm not sure if 8009 is even necessary but it was listed in the service ports so sue me. 
## Bridges (WIP)
1. So far I am looking into enabling app services via the values.yaml file with the appropriate configurations but if that fails I believe I can enable them via the 'additional' property.

## Cloudflare again
Now that the ingresses are all setup we can point the tunnel to them and watch the magic.
1. While in the tunnel configuration, go to 'Public hostnames' at the top.
2. Click 'Add a public hostname'.
3. Type the subdomain that is in the ingress for the particular service. In the case of element web type 'chat' in the subdomain section (These can be whatever you want they just have to match in the ingress and on cloudflare.)
4. Select your domain which should be the one that you purchased and changed the nameservers of.
5. In the 'Service Type' choose 'HTTP'.
6. Go back to your terminal and execute the command ```sudo kubectl get svc -n nginx``` (The '-n nginx' should be whichever namespace you installed the ingress controller in.)
7. Make note of which nodeport is being mapped to the 80 container port. it will look like '80:30000'. You want the 300000 part.
8. Make note of the ip adress of any of your nodes like 192.168.0.52. If on Ubuntu this can be found with the comand ```ip addr show``` and find eth0 and make note of the numbers between 'inet' and '/'.
9. In the 'URL' field on cloudflare type the ip adress you just found with a colon and then the node port from step 7. It will look like this '192.168.0.52:30000'
10. Click 'Save' at the bottom right.
11. Repeat these steps for the rest of the services defined in the values.yaml file from earlier. The only thing that should be changing between each public hostname entry is the subdomain.
12. For the case of serverName from the values.yaml file you may not have a subdomain just leave the field blank in cloudflare if that's the case.
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
