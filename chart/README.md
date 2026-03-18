# Monstera Helm Chart

Helm chart for deploying [Monstera](https://github.com/chairswithlegs/monstera): the server (API), the UI, and optionally PostgreSQL and NATS. When PostgreSQL or NATS are disabled, you supply your own instances and set the connection details in the server Secret.

## Prerequisites

- Kubernetes 1.23+
- Helm 3.x
- (Optional) Ingress controller if you use the chart ingress

## Creating the server Secret (required)

The server reads all sensitive configuration from a single Secret you create before installing. The chart does **not** create this Secret.

### Required keys

| Key | Required when | Description |
|-----|---------------|-------------|
| `SECRET_KEY_BASE` | Always | 64+ hex characters for signing and key derivation |
| `DATABASE_USERNAME` | Always | PostgreSQL username |
| `DATABASE_PASSWORD` | Always | PostgreSQL password |
| `NATS_URL` | `nats.enabled` is `false` | NATS server URL (bundled URL is injected automatically when enabled) |
| `EMAIL_SMTP_USERNAME` | `email.driver` is `smtp` | SMTP username |
| `EMAIL_SMTP_PASSWORD` | `email.driver` is `smtp` | SMTP password |

Generate a strong `SECRET_KEY_BASE` with:

```bash
openssl rand -hex 32
```

### Example: create the Secret with kubectl

```bash
kubectl create secret generic monstera-server-env \
  --from-literal=SECRET_KEY_BASE="$(openssl rand -hex 32)" \
  --from-literal=DATABASE_USERNAME=monstera \
  --from-literal=DATABASE_PASSWORD=YOUR_DB_PASSWORD
```

Set `server.existingSecret: monstera-server-env` in your values file.

## Install

1. Create the server Secret (see above) in the target namespace.
2. Update dependencies and install:

```bash
helm dependency update chart/
helm install monstera chart/ -f myvalues.yaml -n <namespace>
```

## Parameters

### Global

| Name             | Description                                                          | Value        |
| ---------------- | -------------------------------------------------------------------- | ------------ |
| `instanceName`   | Display name for the instance, shown in the UI and API responses     | `Monstera`   |
| `instanceDomain` | Public hostname of the instance (e.g. social.example.com). Required. | `""`         |
| `uiDomain`       | Hostname for the UI. Defaults to instanceDomain if empty.            | `""`         |
| `appEnv`         | Application environment. Use `production` for live deployments.      | `production` |
| `logLevel`       | Log verbosity. One of: debug, info, warn, error.                     | `info`       |

### Server

| Name                         | Description                                                                                                                                                                                                                                                                      | Value                                    |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| `server.existingSecret`      | Name of a pre-existing Secret containing sensitive server config. Always required: SECRET_KEY_BASE, DATABASE_USERNAME, DATABASE_PASSWORD. Also required when nats.enabled is false: NATS_URL. Also required when email.driver is smtp: EMAIL_SMTP_USERNAME, EMAIL_SMTP_PASSWORD. | `""`                                     |
| `server.image.repository`    | Server container image repository                                                                                                                                                                                                                                                | `ghcr.io/chairswithlegs/monstera/server` |
| `server.image.tag`           | Server container image tag                                                                                                                                                                                                                                                       | `latest`                                 |
| `server.image.pullPolicy`    | Server container image pull policy                                                                                                                                                                                                                                               | `IfNotPresent`                           |
| `server.replicaCount`        | Number of server pod replicas                                                                                                                                                                                                                                                    | `1`                                      |
| `server.resources`           | CPU/memory resource requests and limits for the server container                                                                                                                                                                                                                 | `{}`                                     |
| `server.extraEnv`            | Extra environment variables to inject into server pods                                                                                                                                                                                                                           | `[]`                                     |
| `server.ingress.enabled`     | Enable Ingress for the server API                                                                                                                                                                                                                                                | `false`                                  |
| `server.ingress.className`   | Ingress class name for the server Ingress                                                                                                                                                                                                                                        | `""`                                     |
| `server.ingress.annotations` | Annotations for the server Ingress                                                                                                                                                                                                                                               | `{}`                                     |
| `server.ingress.hosts`       | Host rules for the server Ingress. Each entry defines a `host` and `paths` array (path, pathType). Default paths: /api, /oauth, /.well-known, /users, /inbox.                                                                                                                    | `[]`                                     |
| `server.ingress.tls`         | TLS configuration for the server Ingress                                                                                                                                                                                                                                         | `[]`                                     |

### UI

| Name                     | Description                                                                                                     | Value                                |
| ------------------------ | --------------------------------------------------------------------------------------------------------------- | ------------------------------------ |
| `ui.image.repository`    | UI container image repository                                                                                   | `ghcr.io/chairswithlegs/monstera/ui` |
| `ui.image.tag`           | UI container image tag                                                                                          | `latest`                             |
| `ui.image.pullPolicy`    | UI container image pull policy                                                                                  | `IfNotPresent`                       |
| `ui.ingress.enabled`     | Enable Ingress for the UI                                                                                       | `false`                              |
| `ui.ingress.className`   | Ingress class name for the UI Ingress                                                                           | `""`                                 |
| `ui.ingress.annotations` | Annotations for the UI Ingress                                                                                  | `{}`                                 |
| `ui.ingress.hosts`       | Host rules for the UI Ingress. Each entry defines a `host` and `paths` array (path, pathType). Default path: /. | `[]`                                 |
| `ui.ingress.tls`         | TLS configuration for the UI Ingress                                                                            | `[]`                                 |

### Database

| Name            | Description                                                              | Value      |
| --------------- | ------------------------------------------------------------------------ | ---------- |
| `database.name` | PostgreSQL database name                                                 | `monstera` |
| `database.port` | PostgreSQL port                                                          | `5432`     |
| `database.host` | External PostgreSQL hostname. Required when postgresql.enabled is false. | `""`       |

### PostgreSQL

| Name                                     | Description                                                                                                                                      | Value                      |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | -------------------------- |
| `postgresql.enabled`                     | Deploy the Bitnami PostgreSQL subchart. When false, supply database.host in values and DATABASE_USERNAME/DATABASE_PASSWORD in the server secret. | `true`                     |
| `postgresql.image.repository`            | PostgreSQL container image repository                                                                                                            | `bitnamilegacy/postgresql` |
| `postgresql.auth.existingSecret`         | Secret containing DATABASE_PASSWORD for the bundled PostgreSQL. Set to the same value as server.existingSecret.                                  | `""`                       |
| `postgresql.primary.persistence.enabled` | Enable persistence for the PostgreSQL primary pod                                                                                                | `true`                     |
| `postgresql.primary.persistence.size`    | PVC size for PostgreSQL data                                                                                                                     | `10Gi`                     |

### NATS

| Name                                      | Description                                                                                                                                                                                                        | Value   |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------- |
| `nats.enabled`                            | Deploy the NATS subchart with JetStream. When false, supply NATS_URL in the server secret. When true, NATS_URL is injected automatically (no auth by default; add nats.config.merge.authorization to enable auth). | `true`  |
| `nats.natsBox.enabled`                    | Deploy the NATS Box subchart. When false, supply NATS_URL in the server secret. When true, NATS_URL is injected automatically (no auth by default; add nats.config.merge.authorization to enable auth).            | `false` |
| `nats.config.jetstream.enabled`           | Enable JetStream                                                                                                                                                                                                   | `true`  |
| `nats.config.jetstream.fileStore.enabled` | Enable file-backed JetStream storage                                                                                                                                                                               | `true`  |
| `nats.config.jetstream.fileStore.dir`     | Directory for JetStream file storage                                                                                                                                                                               | `/data` |
| `nats.config.jetstream.pvc.enabled`       | Enable PVC for JetStream persistence                                                                                                                                                                               | `true`  |
| `nats.config.jetstream.pvc.size`          | PVC size for JetStream data                                                                                                                                                                                        | `10Gi`  |

### Media

| Name                             | Description                                                                                           | Value         |
| -------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------- |
| `media.driver`                   | Media storage driver. `local` provisions a PVC on the server pod; `s3` uses an S3-compatible service. | `local`       |
| `media.baseUrl`                  | Base URL for serving media files (e.g. https://social.example.com/media). Required.                   | `""`          |
| `media.localPath`                | Mount path for local media storage. Required when driver is local.                                    | `/data/media` |
| `media.cdnBase`                  | Optional CDN base URL. When set, media links use this prefix instead of baseUrl.                      | `""`          |
| `media.maxBytes`                 | Maximum upload size in bytes.                                                                         | `10485760`    |
| `media.s3.bucket`                | S3 bucket name. Required when driver is s3.                                                           | `""`          |
| `media.s3.region`                | S3 region. Required when driver is s3.                                                                | `""`          |
| `media.s3.endpoint`              | S3-compatible endpoint URL. Optional; leave empty for AWS S3. Set for non-AWS providers (e.g. MinIO). | `""`          |
| `media.persistence.enabled`      | Enable PVC for local media storage                                                                    | `true`        |
| `media.persistence.size`         | PVC size for local media                                                                              | `10Gi`        |
| `media.persistence.storageClass` | StorageClass for the media PVC. Leave empty to use the cluster default.                               | `""`          |

### Email

| Name              | Description                                                                                                                             | Value      |
| ----------------- | --------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `email.driver`    | Email driver. `noop` disables sending; `smtp` sends via SMTP (supply EMAIL_SMTP_USERNAME and EMAIL_SMTP_PASSWORD in the server secret). | `noop`     |
| `email.from`      | Sender address for outgoing email. Required when driver is smtp.                                                                        | `""`       |
| `email.fromName`  | Display name for the sender. Defaults to the instance name.                                                                             | `Monstera` |
| `email.smtp.host` | SMTP server hostname. Required when driver is smtp.                                                                                     | `""`       |
| `email.smtp.port` | SMTP server port.                                                                                                                       | `587`      |

## Configuration notes

### Bundled PostgreSQL

When `postgresql.enabled: true`, the chart injects `DATABASE_HOST` automatically. Set `postgresql.auth.existingSecret` to the same value as `server.existingSecret` so the bundled PostgreSQL reads `DATABASE_PASSWORD` from the same secret as the server. The default DB username is `monstera` — set `DATABASE_USERNAME: monstera` in your secret (or override `postgresql.auth.username` to a different value and match it in the secret).

### Bundled NATS

When `nats.enabled: true`, the chart injects `NATS_URL` automatically pointing to the bundled instance (no auth). To add authentication, configure `nats.config.merge.authorization` and override `NATS_URL` via `server.extraEnv`.

### External PostgreSQL or NATS

Set `postgresql.enabled: false` or `nats.enabled: false` and supply the credentials in your server Secret (`DATABASE_USERNAME`, `DATABASE_PASSWORD`, or `NATS_URL`).

### Local media and StorageClass

When `media.driver: local`, the chart creates a PVC for the server. Set `media.persistence.storageClass` to use a specific StorageClass; leave empty for the cluster default.

### S3 media

Set `media.driver: s3` and configure `media.s3.bucket`, `media.s3.region`, and (for non-AWS providers like MinIO) `media.s3.endpoint` in your values. S3 credentials are supplied via the AWS SDK credential chain (IAM role, `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY` env vars, etc.).

## Upgrading

1. Ensure the server Secret exists and is up to date.
2. Run `helm dependency update chart/` if Chart.yaml dependencies changed.
3. Run `helm upgrade monstera chart/ -f myvalues.yaml -n <namespace>`.

## Uninstall

```bash
helm uninstall monstera -n <namespace>
```

The server Secret you created is not removed by Helm; delete it manually if desired.

## More

- Application configuration and env vars: see the main [Monstera README](https://github.com/chairswithlegs/monstera) and `internal/config` in the repo.
