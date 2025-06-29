server:
  service:
    type: LoadBalancer
    loadBalancerSourceRanges:
      - "5.29.9.128/32"
  ingress:
    enabled: false

# Do NOT include the 'configs.repositories' block if you manage the repo secret with Terraform.
# The 'repoServer' will automatically discover the secret by label.
# The following disables Helm-side repo management and avoids the template error.

configs:
  secret:
    createSecret: true  # We'll create the repo secret manually

controller:
  resources: {}
repoServer:
  resources: {}
applicationSet:
  enabled: true
