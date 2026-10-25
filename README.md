# Coolify Nginx security refresh

**Technical report, reproducible fix and operational case study by [mtalavi](https://github.com/mtalavi).**

[Upstream issue #12311](https://github.com/coollabsio/coolify/issues/12311) · [Technical report](CASE_STUDY.md) · [Test evidence](VERIFICATION.md) · [Apache-2.0](LICENSE)

A current application release can still contain an older dependency. During Coolify maintenance, we verified that the official **v4.5.0** amd64 image shipped **Nginx 1.31.2-r1**, then built and tested a narrowly scoped refresh.

| Check | Official image | Tested candidate |
|---|---|---|
| Nginx package | 1.31.2-r1 | 1.31.8-r1 |
| Nginx configuration and permissions | Baseline | Identical |
| Application file-tree hash | Baseline | Identical |
| Runtime user | www-data | www-data |
| Node / PHP | 24.22.1 / 8.4.27 | Unchanged |
| Candidate config / static HTTP | — | Pass /200 |

The contribution is the **verified Coolify packaging finding, tested mitigation and reproducible evidence**. The Nginx vulnerabilities were already publicly documented. Default Coolify exploitability and first-discovery status have not been established.

## Reproduce the fix

```sh
git clone https://github.com/mtalavi/coolify-nginx-case-study.git
cd coolify-nginx-case-study
docker build --platform linux/amd64 -t coolify-nginx-refresh:4.5.0 .
sh smoke-test.sh coolify-nginx-refresh:4.5.0
```

The temporary test has no network, published ports, host mounts or production DB. It checks syntax and a static HTTP response, then removes its container. It does not prove full application acceptance.

Read the [report's deployment and rollback steps](CASE_STUDY.md#production-use-and-rollback) before considering production use. A custom image must be maintained across future Coolify updates.

## Credit and reuse

Copyright **2026 mtalavi**. Apache 2.0 permits reuse and commercial use while requiring preservation of applicable copyright/attribution notices; see [LICENSE](LICENSE) and [NOTICE](NOTICE). Upstream projects retain their own licenses.

To cite this work: **mtalavi (2026), “Coolify Nginx security refresh,” GitHub technical report.** [Citation metadata](CITATION.cff)

If this helps you audit an installation, a star helps others find it. Reproduction results and corrections are welcome.

AI assistance: OpenAI Codex helped investigate and write this report. The documented checks were executed. This is an independent report, not an upstream-endorsed advisory or a peer-reviewed paper.

