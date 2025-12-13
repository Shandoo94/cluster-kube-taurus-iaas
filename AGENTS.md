# Agent Guidelines for cluster-kube-taurus-iaas

## Overview
Kubernetes GitOps repository using k0s with built-in CNI and ArgoCD. Manages declarative infrastructure with app-of-apps pattern.

## Build/Lint/Test Commands
- Validate single YAML: `kubectl apply --dry-run=client -f <file>`
- Lint all YAML: `yamllint .`
- Test ArgoCD sync: `kubectl apply -f root-argocd-app.yaml --dry-run=server`

## Code Style & Conventions
- **File Format**: YAML only (`.yaml` preferred, never `.yml`)
- **Indentation**: 2 spaces, no tabs
- **Structure**: Apps in `apps/<namespace>/<app-name>/` with kustomization.yaml; infra configs in `infra/`
- **Naming**: kebab-case for files/dirs (e.g., `app-config.yaml`)
- **ArgoCD Apps**: Define ApplicationSets in `appsets/` with `automated.prune: true` and `syncOptions: CreateNamespace=true`
- **Kustomization**: Use `resources:` list; reference versioned external URLs (e.g., ArgoCD v3.1.7)
- **Helm**: Use Chart.yaml with dependencies pointing to official repos when needed
- **Namespace**: Always specify in kustomization.yaml `namespace:` field or resource metadata
- **Comments**: Add YAML comments for k0s-specific configs (security contexts, host paths, network settings)
- **Repository**: `https://github.com/Shandoo94/cluster-kube-taurus-iaas.git`, branch `master`

## Git Commit Conventions
- **Format**: Use conventional commits: `type(scope): description`
- **Types**: 
  - `feat`: New feature or component (e.g., `feat(lb): added MetalLB as load balancer`)
  - `fix`: Bug fix or correction (e.g., `fix(cert): fix the service name generation`)
- **Scopes**: Use lowercase abbreviations for scope
  - `argocd`: ArgoCD components
  - `lb`: Load balancer
  - `cert`: cert-manager
  - `secret`: sealed-secrets
  - `csi`: CSI drivers
  - `apps`: Application definitions
  - `infra`: Infrastructure configs
- **Description**: Use lowercase, imperative mood ("add" not "added", "fix" not "fixed" in title)
- **Body**: Add explanation when needed, especially for:
  - Configuration fixes (explain what was wrong and why)
  - Helm overrides (explain why `fullnameOverride` or other values are needed)
  - Size/capacity changes (explain calculations, e.g., "The block is now actually 20 entries in size")
  - Installation methods (e.g., "installation via Helm chart")
- **Examples**:
  ```
  feat(lb): added MetalLB as load balancer
  
  fix(cert): fix the service name generation
  
  The service names also contain the release name, which messes with the
  default configuration.
  Passing `fullnameOverride: cert-manager` should fix this.
  ```

## Best Practices
- **Versioning**: Always pin external resources to specific versions (e.g., `v0.15.2`, `v1.19.1`)
- **Helm Charts**: 
  - Use Chart.yaml with dependencies for Helm-based apps
  - Override default names with `fullnameOverride` when service names conflict with defaults
  - Enable CRDs explicitly in values.yaml (`crds.enabled: true`)
- **Kustomization**:
  - Always set `namespace:` field explicitly
  - Reference versioned URLs from official repositories
  - List local resources after external resources
- **Configuration Files**:
  - Separate config from deployment manifests (e.g., `metallb-config.yaml`)
  - Keep infrastructure-specific settings in `infra/cloud-init/`
- **Changes**: Make atomic commits - one feature/fix per commit with clear scope

## Special Notes
- k0s cluster with built-in kube-router CNI; no external CNI installation needed
- ApplicationSet auto-discovers `apps/*/*` pattern; namespace extracted from `path[1]`
- Never modify generated files or `.git/`; preserve existing security contexts and capability sets
- Root app enables selfHeal; child apps use prune for full GitOps automation
