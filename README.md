# Monstera Helm Chart

Helm chart for deploying [Monstera](https://github.com/chairswithlegs/monstera)—a self-hosted ActivityPub / Mastodon-compatible server—on Kubernetes.

This repository contains **only the Helm chart**. The application itself is [Monstera](https://github.com/chairswithlegs/monstera).

## Prerequisites

- Kubernetes 1.23+
- Helm 3.x

## Quick start

1. **Create the server Secret** in your target namespace. The chart does not create it. See [chart/README.md](chart/README.md) for required keys and examples.
2. **Install from the `chart/` directory:**

   ```bash
   cd chart
   helm dependency update
   helm install monstera . -f myvalues.yaml -n <namespace>
   ```

   Set `server.existingSecret` in your values to the name of the Secret you created.

Full install steps, Secret details, and configuration options are in **[chart/README.md](chart/README.md)**.

## What the chart deploys

- **Server**: Monstera API (Deployment + Service)
- **UI**: Next.js static frontend served by nginx (Deployment + Service + ConfigMap)
- **Migration job**: Optional pre-install/pre-upgrade Job for database migrations
- **Optional subcharts**: PostgreSQL (Bitnami) and NATS; when disabled, you provide your own and set `DATABASE_URL` / `NATS_URL` in the server Secret
- **Media**: PVC for local media when `media.driver: local`
