# Steps to setup ess (so far)
1. Install helm
2. Copy and paste the hostnames.yaml file from the ess-helm repo.
3. Edit the hostnames.yaml file to have:
```
ingress:
  className: nginx
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
From here I have tried disabling matrixAuthenticationService but it messes everything up. I have also tried disabling TLS from here but I tested it when I disabled MAS so it may have worked. You could also disable proxying in Cloudflare's DNS entries but I couldn't get the server to work when I did it that way. The issue may have been that I didn't setup any cert management. 

5. Install ess from the ess-helm github
6. If using cloudflare disable the tls in each ingress by using KUBE_EDITOR=nano and setting:
```
 tls: []
```
9. The default ess ingress is bugged with this method so I had to create a new ingress without any of the paths from the previous ingress.
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: matrix-ingress
  namespace: ess
  annotations:
    qbittorrent.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - host: matrix.domain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: ess-synapse
            port:
              number: 8008
```
# Current challenges
1. MAS must be enabled for the server to run properly and I would like to disable it.
2. I would like to enable user registration without email.
3. I would like to incorporate bridges into the setup as well.
