# Cloud Architecture Design for Innovate Inc.

## Executive Summary

This document outlines a comprehensive cloud infrastructure design for Innovate Inc.'s web application, leveraging AWS services with a focus on managed Kubernetes (EKS), security, scalability, and cost optimization. The architecture is designed to support growth from hundreds to millions of users while maintaining security and operational efficiency.

## 1. Cloud Environment Structure

### 1.1 AWS Account Strategy

We recommend a **three-account structure** for Innovate Inc.:

```
┌─────────────────────────────────────────────────────────────┐
│                    AWS Organization                          │
├─────────────────────┬──────────────────┬───────────────────┤
│   Production        │    Staging       │   Shared Services │
│   Account          │    Account       │   Account         │
│   (Prod workloads) │  (Pre-prod test) │  (CI/CD, Logs)   │
└────────────────────┴──────────────────┴───────────────────┘
```

**Justification:**
- **Production Account**: Isolated production workloads with strict access controls
- **Staging Account**: Safe testing environment that mirrors production
- **Shared Services Account**: Centralized CI/CD, logging, and monitoring
- **Benefits**: 
  - Blast radius containment
  - Clear billing separation
  - Simplified compliance and auditing
  - Independent scaling of environments

### 1.2 Account Configuration

- **AWS Organizations**: Centralized billing and governance
- **AWS SSO**: Single sign-on for all accounts
- **Service Control Policies (SCPs)**: Enforce security guardrails
- **AWS CloudTrail**: Centralized audit logging in Shared Services account

## 2. Network Design

### 2.1 VPC Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                   AWS Region (us-west-2)                     │
├─────────────────────────────────────────────────────────────┤
│                  VPC: 10.20.0.0/16                          │
├─────────────────────┬────────────────┬─────────────────────┤
│   AZ: us-west-2a   │  AZ: us-west-2b │  AZ: us-west-2c    │
├─────────────────────┼────────────────┼─────────────────────┤
│ Public Subnet       │ Public Subnet   │ Public Subnet      │
│ 10.20.101.0/24     │ 10.20.102.0/24  │ 10.20.103.0/24    │
│ [NAT Gateway]       │ [NAT Gateway]   │ [NAT Gateway]      │
├─────────────────────┼────────────────┼─────────────────────┤
│ Private Subnet      │ Private Subnet  │ Private Subnet     │
│ 10.20.1.0/24       │ 10.20.2.0/24    │ 10.20.3.0/24      │
│ [EKS Worker Nodes]  │ [EKS Worker]    │ [EKS Worker]       │
├─────────────────────┼────────────────┼─────────────────────┤
│ DB Subnet          │ DB Subnet       │ DB Subnet          │
│ 10.20.11.0/24      │ 10.20.12.0/24   │ 10.20.13.0/24     │
│ [RDS PostgreSQL]    │ [RDS Standby]   │                    │
└─────────────────────┴────────────────┴─────────────────────┘
```

### 2.2 Network Security

#### Security Layers:
1. **Network ACLs**: Stateless subnet-level filtering
2. **Security Groups**: Stateful instance-level filtering
3. **AWS WAF**: Application layer protection on ALB
4. **AWS Shield Standard**: DDoS protection (free)

#### Security Group Strategy:
```yaml
ALB Security Group:
  - Ingress: 443 from 0.0.0.0/0 (HTTPS)
  - Ingress: 80 from 0.0.0.0/0 (HTTP redirect)
  - Egress: All to EKS nodes

EKS Node Security Group:
  - Ingress: All from ALB SG
  - Ingress: All from within VPC (node communication)
  - Egress: 443 to 0.0.0.0/0 (ECR, AWS APIs)
  - Egress: 5432 to RDS SG

RDS Security Group:
  - Ingress: 5432 from EKS nodes
  - No public access
```

## 3. Compute Platform - Amazon EKS

### 3.1 EKS Cluster Architecture

```yaml
EKS Cluster: innovate-inc-production
├── Version: 1.31
├── Auto Mode: Enabled
├── Endpoint Access: Private + (VPN Accessible)
└── Add-ons:
    ├── VPC CNI (networking)
    ├── CoreDNS (DNS)
    ├── EBS CSI Driver (storage)
    └── Karpenter (autoscaling)
```

### 3.2 Node Groups Strategy

We utilize **Karpenter** for intelligent autoscaling with custom NodePools:

```yaml
NodePools:
  # General Purpose - Mixed Architecture
  - name: general-mixed
    instanceTypes: 
      - m5.large, m5a.large    # x86
      - m6g.large, m6g.xlarge  # ARM64 (20-40% cheaper)
    capacityTypes: [spot, on-demand]
    limits:
      cpu: 1000
      memory: 1000Gi
    
  # Backend Processing - Stable
  - name: backend-stable
    instanceTypes: [m5.xlarge, m5a.xlarge]
    capacityTypes: [on-demand]
    taints:
      - key: workload
        value: backend
        effect: NoSchedule
```

### 3.3 Scaling Strategy

1. **Horizontal Pod Autoscaler (HPA)**: Scale pods based on CPU/memory
2. **Vertical Pod Autoscaler (VPA)**: Right-size pod resources
3. **Karpenter**: Automatic node provisioning based on pod requirements

### 3.4 Containerization Strategy

#### Image Building:
```yaml
CI/CD Pipeline (GitHub Actions):
├── Build: Multi-stage Dockerfile
├── Scan: Trivy security scanning
├── Test: Unit & integration tests
├── Push: Amazon ECR
└── Deploy: ArgoCD GitOps
```

#### Registry Structure:
```
ECR Repositories:
├── innovate-inc/backend
│   ├── Tags: v1.0.0, v1.0.1, latest
│   └── Lifecycle: Keep last 10 versions
└── innovate-inc/frontend
    ├── Tags: v1.0.0, v1.0.1, latest
    └── Lifecycle: Keep last 10 versions
```

#### Deployment Process:
```yaml
GitOps with ArgoCD:
├── Git Repository Structure:
│   ├── /base                    # Shared configurations
│   │   ├── backend/
│   │   │   ├── deployment.yaml
│   │   │   ├── service.yaml
│   │   │   ├── configmap.yaml
│   │   │   └── hpa.yaml
│   │   └── frontend/
│   │       ├── deployment.yaml
│   │       ├── service.yaml
│   │       └── configmap.yaml
│   ├── /environments
│   │   ├── staging/
│   │   │   ├── kustomization.yaml
│   │   │   ├── patches/
│   │   │   │   ├── backend-patch.yaml
│   │   │   │   └── frontend-patch.yaml
│   │   └── production/
│   │       ├── kustomization.yaml
│   │       ├── patches/
│   │       │   ├── backend-patch.yaml
│   │       │   ├── frontend-patch.yaml
│   │       │   └── resource-limits.yaml
│   │       ├── policies/         # Network/Security Policies
│   │       │   ├── network-policy.yaml
│   │       │   └── pod-security-policy.yaml
│   └── /charts                   # Helm charts
│       └── common-services/
│
├── ArgoCD Configuration:
│   ├── Apps of Apps Pattern:
│   │   ├── root-app.yaml        # Parent application
│   │   ├── staging-apps.yaml    # All staging apps
│   │   └── production-apps.yaml # All production apps
│   │
│   ├── Sync Policies:
│   │   ├── Staging:
│   │   │   ├── Automated: Yes
│   │   │   ├── Self-Heal: Yes
│   │   │   └── Prune: Yes
│   │   └── Production:
│   │       ├── Automated: No (Manual approval)
│   │       ├── Self-Heal: No
│   │       ├── Prune: No
│   │       └── Sync Window: Tue-Thu 10:00-16:00
│   │
│   └── RBAC Configuration:
│       ├── Dev Team: Read-only prod, Full staging
│       ├── SRE Team: Full access all environments
│       └── CI/CD: Deploy automatically to staging only
│
├── Deployment Workflow:
│   ├── 1. Developer Push:
│   │   └── Feature branch → PR → Review
│   ├── 2. Staging Deploy:
│   │   ├── Merge to main
│   │   ├── CI builds & pushes image
│   │   ├── Updates staging/patches/
│   │   └── ArgoCD auto-syncs staging
│   ├── 3. Production Deploy:
│   │   ├── Tag release (v1.2.3)
│   │   ├── CI creates PR to production/
│   │   ├── SRE reviews & approves PR
│   │   ├── Manual ArgoCD sync
│   │   └── Progressive rollout (25% → 50% → 100%)
│   │
│   └── 4. Rollback Process:
│       ├── ArgoCD UI: Previous version
│       ├── Git revert: production/ changes
│
└── Security & Compliance:
    ├── Git Repository:
    │   ├── Branch Protection: Required reviews
    │   ├── Signed Commits: GPG required
    │   └── Audit Log: All changes tracked
    ├── Secrets Management:
    │   ├── Hashicorp vault: Secret/TLS/Keys Management
    │   └── Rotation: Configurable
    ├── Image Security:
    │   ├── Admission Controller: OPA Gatekeeper
    │   ├── Image Scanning: Fail on HIGH/CRITICAL
    │   └── Registry: ECR with immutable tags
    └── Compliance Controls:
        ├── Change Tracking: Git commit history
        ├── Approval Process: PR + ArgoCD manual
        ├── Audit Trail: CloudTrail + ArgoCD events
        └── Backup: Git repo + ArgoCD config backups
```

## 4. Database - Amazon RDS for PostgreSQL

### 4.1 RDS Configuration

```yaml
RDS PostgreSQL:
├── Engine: PostgreSQL 15.4
├── Instance Class: db.r6g.large (Graviton2)
├── Multi-AZ: Yes (automatic failover)
├── Storage: 
│   ├── Type: GP3 SSD
│   ├── Size: 100 GB (autoscaling to 1TB)
│   └── IOPS: 3000 (burstable)
├── Encryption: AWS KMS 
└── Network: Database Private subnets only
```

### 4.2 Backup Strategy

```yaml
Automated Backups:
├── Retention: 7 days
├── Backup Window: 03:00-04:00 UTC
└── Point-in-Time Recovery: Enabled

Manual Snapshots:
├── Frequency: Weekly (Sunday)
├── Retention: 30 days
└── Cross-Region Copy: us-east-1 (DR)
```

### 4.3 High Availability & Disaster Recovery 

1. **Multi-AZ Deployment**: Automatic failover in <60 seconds
2. **Read Replicas**: 2 replicas for read scaling
3. **Connection Pooling**: PgBouncer on Kubernetes
4. **Disaster Recovery**:
   - RPO: 5 minutes (continuous backup)
   - RTO: 30 minutes (automated recovery)
   - DR Region: us-east-1 with daily snapshot copies

## 5. Security Architecture

### 5.1 Security Layers

```
┌─────────────────────────────────────────┐
│         AWS WAF (Layer 7)               │
├─────────────────────────────────────────┤
│     Application Load Balancer           │
│         (TLS Termination)               │
├─────────────────────────────────────────┤
│      AWS Shield (DDoS Protection)       │
├─────────────────────────────────────────┤
│         Security Groups                 │
├─────────────────────────────────────────┤
│           Network ACLs                  │
├─────────────────────────────────────────┤
│        Private Subnets Only             │
└─────────────────────────────────────────┘
```

### 5.2 Data Protection

- **Encryption at Rest**: AWS KMS for RDS, EBS, S3
- **Encryption in Transit**: TLS 1.3 everywhere
- **Secrets Management**: Hashicorp Vault 
- **Database Credentials**: IAM database authentication

## 6. Cost Optimization Strategy

### 6.1 Compute Optimization
- **Spot Instances**: Right % usage for stateless apps
- **ARM64 Instances**: Graviton2/3 for 20-40% savings
- **Karpenter**: Right-sized instances, aggressive consolidation
 
### 6.2 Database Optimization
- **Reserved Instances**: 1-year commitment for RDS (30% savings)
- **Graviton2**: db.r6g instances (15% cheaper)
- **Storage**: GP3 vs GP2 (20% savings)
2

## 7. CI/CD Architecture

```yaml
GitHub Actions Pipeline:
├── Source: GitHub (main branch)
├── Build:
│   ├── Docker build (multi-stage)
│   ├── Security scan (Trivy)
│   └── Unit tests
├── Push: Amazon ECR
├── Deploy:
│   ├── Update k8s manifests
│   └── ArgoCD auto-sync
└── Monitoring: Datadog alerts
```

## 8. Monitoring & Observability

- **Metrics**: Prometheus + Grafana
- **Logs**: CloudWatch Logs/Fluentd/Loki 
- **Traces**: OpenTelemetry
- **Alerts**: PagerDuty integration

## 10. Conclusion

This architecture provides Innovate Inc. with:
- **Scalability**: From hundreds to millions of users
- **Security**: Multiple layers of protection
- **Cost-efficiency**: 40-60% savings through spot/ARM
- **Reliability**: Multi-AZ, auto-healing infrastructure
- **Simplicity**: Managed services reduce operational overhead

The use of EKS with Karpenter provides the flexibility to handle rapid growth while maintaining cost control. The GitOps approach ensures reliable, auditable deployments, and the multi-account strategy provides the necessary isolation for a growing startup.

To deploy:
```bash
cd /tenants/company-b/production
terraform init
terraform plan
terraform apply
```
