# Agent Guidelines for cluster-kube-taurus-iaas

## Overview
Kubernetes GitOps repository using k0s with built-in CNI and ArgoCD. Manages declarative infrastructure with app-of-apps pattern.

## Insructions
Be conservative with the amount of shell commands you use for debugging. Thing about what information you need and then run only one command at a time.
For access to the cluster with `kubectl`, append `--kubeconfig ~/.kube/taurus`.
You are not allowed to look up secrets.

## Build/Lint/Test Commands
- Validate single YAML: `kubectl apply --dry-run=client -f <file>`
- Validate kustomization with Helm: `kubectl kustomize <path> --enable-helm`
- Test ArgoCD sync: `kubectl apply -f root-argocd-app.yaml --dry-run=server`

## Code Style & Conventions
- **File Format**: YAML only (`.yaml` preferred, never `.yml`)
- **Indentation**: 2 spaces, no tabs
- **Structure**: Apps in `apps/<namespace>/<app-name>/` with kustomization.yaml; infra configs in `infra/`
- **Naming**: kebab-case for files/dirs (e.g., `app-config.yaml`)
- **Kustomization**: Use `resources:` list; reference versioned external URLs (e.g., ArgoCD v3.1.7)
- **Helm Charts**: Use kustomization.yaml `helmCharts:` field with `valuesFile:` referencing values.yaml (NEVER use Chart.yaml wrapper charts)
  - Keep values.yaml separate from kustomization.yaml (do NOT use valuesInline)
  - ArgoCD configured with `kustomize.buildOptions: --enable-helm` globally
- **Namespace**: Always specify in kustomization.yaml `namespace:` field or resource metadata
- **Comments**: Add YAML comments for k0s-specific configs (security contexts, host paths, network settings)

## Git Commit Conventions
**Format**: Use conventional commits: `type(scope): description`
**Types**: Use standard types, such as `feat`, `fix`, `refactor`, `chore` etc.
**Scopes**: Use lowercase abbreviations for scope
- `argocd`: ArgoCD components
- `lb`: Load balancer
- `cert`: cert-manager
- `secret`: sealed-secrets
- `csi`: CSI drivers
- `apps`: Application definitions
- `infra`: Infrastructure configs
**Description**: Use lowercase, imperative mood ("add" not "added", "fix" not "fixed" in title)
**Body**: Add explanation when needed, especially for:
- Configuration fixes (explain what was wrong and why)
**Changes**: Make atomic commits - one feature/fix per commit with clear scope
