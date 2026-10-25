# Technical report: Nginx patch lag in Coolify v4.5.0

**Author:** [mtalavi](https://github.com/mtalavi)  
**Published:** 25 October 2026  
**Upstream:** [coollabsio/coolify#12311](https://github.com/coollabsio/coolify/issues/12311)

## Finding

After updating Coolify, we checked the dependency inside an independent copy of the official image. The application was v4.5.0; the bundled Nginx package was still 1.31.2-r1. The [release Dockerfile](https://github.com/coollabsio/coolify/blob/5ca69705d681da46028ea15a8a39d90a4ebcce89/docker/production/Dockerfile) pinned that exact version, as did the main source checked during the investigation.

The immutable Docker Hub image index was:

```text
sha256:d96931bef961ab5c173edfca190e03d4b77e93dee622da780ddfa22cfa2b77cf
```

Inspection ran on linux/amd64 without network access, host mounts, credentials or published ports. Node 24.22.1 and PHP 8.4.27, with PHP upload progress disabled, were already present. This finding concerns the Nginx package.

## What the security evidence means

The [official Nginx advisory list](https://nginx.org/en/security_advisories.html) places 1.31.2 in affected ranges for several known issues. Examples:

| Advisory | Required feature/configuration | Mainline fix begins |
|---|---|---|
| CVE-2026-42533 | map with regular expressions | 1.31.3 |
| CVE-2026-60005 | slice module | 1.31.3 |
| CVE-2026-15176 | alias with rewrite | 1.31.7 |

These upstream advisories have configuration-specific prerequisites. Deployment severity depends on enabled directives, reachable request paths and any vendor backports. This investigation verified the shipped package, traced its version pin and tested the refresh.

## Method and result

We compared the immutable official image with a derivative built from the same digest. The [Dockerfile](Dockerfile) upgrades only Nginx to 1.31.8-r1 through the signed nginx.org Alpine repository. It preserves the **whole** `/etc/nginx` tree and restores `USER www-data`.

The Nginx configuration file hashes, ownership and permissions matched before and after. The application file-tree hash, Node/PHP versions and runtime user also matched. The candidate passed `nginx -t` and served `/build/manifest.json` with HTTP 200 during an isolated startup.

The exact package was available for x86_64 and aarch64. Runtime execution was tested only on amd64. Full upstream multi-stage builds, ARM runtime tests and database-backed application acceptance were outside this check. [Evidence and hash method](VERIFICATION.md).

## The proposed upstream fix

The [patch](upstream-nginx-pin.patch) changes the shared production version argument:

```diff
-ARG NGINX_VERSION=1.31.2-r1
+ARG NGINX_VERSION=1.31.8-r1
```

Upstream status: submitted for triage in issue #12311. Existing reports were checked; the closest matches concerned a development-image pin and header buffers. Private reports cannot be searched.

## Production use and rollback

1. Record the current Coolify image, version and rendered Compose configuration. Make a consistent configuration/data backup and verify recovery.
2. Build the candidate separately and run the isolated test from the [README](README.md). Keep the current image available.
3. Use the existing deployment path to change **only** the Coolify image override. Preserve all other settings, user, mounts, networks, ports, secrets and resource limits. Do not overwrite an existing custom Compose file with a generic example.
4. Recreate the Coolify service and verify its actual image/version, dashboard, health, queues and connected applications. A static200 alone is insufficient.
5. If checks fail, restore the previous image setting and recreate through the same path. This package-only example does not call for restoring the whole application database.
6. Before a later Coolify update, stage a matching derivative or return to a verified fixed official image. A custom tag must not silently freeze Coolify at an old application version.

## Attribution

Copyright 2026 mtalavi. [Apache-2.0](LICENSE); retain applicable [NOTICE](NOTICE) attribution.
