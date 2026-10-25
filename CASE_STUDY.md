# Case study: updating Coolify did not update this Nginx pin

**Author:** [mtalavi](https://github.com/mtalavi)  
**Date:** 25 October 2026

### Starting point

Routine maintenance brought our Coolify instances to v4.5.0. We then checked an independent copy of the official image locally. It contained Nginx1.31.2-r1; the production Dockerfile pinned that exact package.

The immutable Docker Hub index was:

```text
sha256:d96931bef961ab5c173edfca190e03d4b77e93dee622da780ddfa22cfa2b77cf
```

### What we changed

We built a derivative image from that digest and upgraded to Nginx1.31.8-r1 using the signed nginx.org Alpine repository. We saved and restored the **whole** `/etc/nginx` tree, including templates and permissions, rather than replacing it with package defaults. The image still runs as `www-data`.

The corresponding [upstream proposal](upstream-nginx-pin.patch) changes only the shared version argument. It is a proposal, not an accepted upstream fix.

### How we checked it

Before/after inspection confirmed identical Nginx configuration hashes and ownership/permissions, application file-tree hash, runtime user and Node/PHP versions. An isolated startup passed `nginx -t` and returned HTTP200 for `/build/manifest.json`.

The package exists for both supported CPU architectures, but only amd64 was executed locally. No exploit attempt or full database-backed acceptance test was performed.

### Practical lesson

Check the running dependency, not just the Coolify release number. Replacing a package inside a live container is temporary; a pinned, tested derivative image is reproducible, but needs maintenance on later updates.

For production, preserve the existing Compose configuration, create a recoverable backup, stage the image and keep the previous image reference. Switch only the Coolify image setting, recreate through the existing deployment path, and verify the dashboard and connected services. Roll back the image setting if validation fails.

### Sources

- [Exact release Dockerfile](https://github.com/coollabsio/coolify/blob/5ca69705d681da46028ea15a8a39d90a4ebcce89/docker/production/Dockerfile)
- [Nginx advisories and fixed versions](https://nginx.org/en/security_advisories.html)
- [Nginx Alpine package index](https://nginx.org/packages/mainline/alpine/v3.24/main/x86_64/APKINDEX.tar.gz)

Copyright2026 mtalavi. Apache-2.0; retain the applicable [NOTICE](NOTICE).

