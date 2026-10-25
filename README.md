# Coolify Nginx refresh: a small case study

By [mtalavi](https://github.com/mtalavi) · Checked **25 October 2026** · [Apache-2.0](LICENSE)

During routine Coolify maintenance, we checked the container's dependencies as well as the application version. Coolify was up to date, but its bundled Nginx was still pinned to an older release.

## What we found

The official **Coolify v4.5.0** amd64 image reports **nginx 1.31.2-r1**. The [release Dockerfile](https://github.com/coollabsio/coolify/blob/5ca69705d681da46028ea15a8a39d90a4ebcce89/docker/production/Dockerfile) pins the same package.

That version appears in affected ranges in the [published Nginx advisories](https://nginx.org/en/security_advisories.html). This is a dependency maintenance finding. We have **not demonstrated an exploit against default Coolify**, and configuration and possible vendor backports still matter.

## The small fix

For upstream, the proposed change is one line:

```diff
-ARG NGINX_VERSION=1.31.2-r1
+ARG NGINX_VERSION=1.31.8-r1
```

For an isolated check, this repo's [Dockerfile](Dockerfile) derives from the exact official image digest, upgrades only Nginx, restores the complete original Nginx configuration, and returns to `www-data`.

```sh
git clone https://github.com/mtalavi/coolify-nginx-case-study.git
cd coolify-nginx-case-study
docker build --platform linux/amd64 -t coolify-nginx-refresh:4.5.0 .
sh smoke-test.sh coolify-nginx-refresh:4.5.0
```

The test starts a temporary container with no network, published ports, host mounts or production database. It checks Nginx syntax and a static HTTP response, then removes that container.

## What passed

The local amd64 package upgrade, `nginx -t`, and static HTTP **200** passed. Nginx configuration hashes and ownership/permissions matched the original. The application file-tree hash, runtime user and Node/PHP versions also stayed the same.

We checked package availability for both x86_64 and aarch64. We did **not** run the full upstream multi-stage build, ARM runtime tests or database-backed application acceptance. See [the short case study](CASE_STUDY.md) and [validation summary](validation.json).

## Before using this in production

This is a reproducible example, not an automatic production installer. Back up configuration and data, retain the previous image, and stage the candidate before changing the existing Coolify image override. Preserve all other Compose settings. After recreation, verify the real image/version, dashboard, queues and connected services; restore the previous image setting if checks fail.

A derived image needs rebuilding and checking for each future Coolify version. Otherwise it can quietly hold the application at an old release.

## Attribution and reuse

Original material here is copyright **2026 mtalavi**, licensed under **Apache 2.0**. Keep the license and applicable attribution from [NOTICE](NOTICE) when redistributing. This does not add a mandatory UI credit or restrict commercial use. Coolify and Nginx retain their own licenses.

This finding was also sent privately to the maintainers. Upstream acceptance is not claimed. AI assistance: OpenAI Codex helped prepare the investigation and writing; the reported checks were actually executed.

