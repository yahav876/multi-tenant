# ArgoCD Helm Chart Values Template
global:
  labels:
%{ for key, value in labels ~}
    ${key}: "${value}"
%{ endfor ~}

# ArgoCD configuration
argo-cd:
  global:
    image:
      tag: "v2.8.4"
  
  # Enable insecure mode for easier initial setup
  configs:
    params:
      server.insecure: true
    
  # Server configuration
  server:
    service:
      type: LoadBalancer
    extraArgs:
      - --insecure
    
    # Enable ingress if needed
    ingress:
      enabled: false
      
  # Repo server configuration  
  repoServer:
    volumes:
      - name: ssh-known-hosts
        configMap:
          name: argocd-ssh-known-hosts-cm
    volumeMounts:
      - mountPath: /app/config/ssh
        name: ssh-known-hosts
        
  # Application controller configuration
  controller:
    enableStatefulSet: false
    
  # Redis configuration
  redis:
    enabled: true
    
  # Notifications controller
  notifications:
    enabled: false
    
  # ApplicationSet controller
  applicationSet:
    enabled: true
    
  # Dex OAuth configuration (disabled for simplicity)
  dex:
    enabled: false

# Create SSH known hosts ConfigMap
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-ssh-known-hosts-cm
  namespace: ${namespace}
  labels:
%{ for key, value in labels ~}
    ${key}: "${value}"
%{ endfor ~}
data:
  ssh_known_hosts: |
    github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg=
    github.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl
    github.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=
