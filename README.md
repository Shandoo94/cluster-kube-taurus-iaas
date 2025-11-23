# cluster-kube-taurus-iaas

GitOps-managed Kubernetes cluster using k0s and ArgoCD for declarative infrastructure management.

## Overview

This repository contains the complete configuration for a k0s Kubernetes cluster managed via GitOps principles. All cluster resources are declaratively defined and automatically synchronized by ArgoCD.

## Directory Structure

```
.
├── apps/                    # Application manifests organized by namespace
│   ├── <namespace>/
│   │   └── <app-name>/     # Each app has its own directory
│   │       ├── kustomization.yaml
│   │       └── ...
├── appsets/                 # ArgoCD ApplicationSets
│   └── appset-apps.yaml    # Auto-discovers apps in apps/*/*
├── infra/                   # Infrastructure configuration
│   ├── k0sctl.yaml         # k0s cluster configuration
│   └── cloud-init/         # Cloud-init configs for nodes
└── root-argocd-app.yaml    # Root ArgoCD Application
```

## Conventions

### Application Structure
- Apps are organized in `apps/<namespace>/<app-name>/`
- Namespace is automatically extracted from directory path by ApplicationSet

### ArgoCD Management
- **Root App**: Syncs ApplicationSets from `appsets/` directory with `selfHeal` enabled
- **ApplicationSet**: Auto-discovers all apps matching `apps/*/*` pattern
- **Sync Policy**: Automated pruning enabled, creates namespaces automatically

### Naming Conventions
- Kustomize resources reference versioned external URLs where applicable

## Deploy Cluster

```bash
# Deploy k0s cluster
k0sctl apply --config infra/k0sctl.yaml

# Get kubeconfig
k0sctl kubeconfig --config infra/k0sctl.yaml > ~/.kube/config

# Deploy ArgoCD root application
kubectl apply -f root-argocd-app.yaml
```
