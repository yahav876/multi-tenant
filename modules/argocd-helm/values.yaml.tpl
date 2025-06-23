server:
  service:
    type: LoadBalancer
    loadBalancerSourceRanges:
      - "5.29.9.128/32"
  ingress:
    enabled: false

configs:
  repositories:
    private-github:
      url: "${git_repo_url}"
      type: git
      name: private-github
      sshPrivateKeySecret:
        name: repo-ssh-secret
        key: sshPrivateKey
  secret:
    createSecret: false  # We'll create the repo secret manually

# Disable unused features if desired
controller:
  resources: {}
repoServer:
  resources: {}
applicationSet:
  enabled: true

