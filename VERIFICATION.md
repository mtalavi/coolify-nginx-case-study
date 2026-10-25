# Verification record

Checked **25 October 2026** on **linux/amd64**. The immutable official image and derivative were inspected locally. The published build and smoke-test recipe was also executed successfully.

| Evidence | Result |
|---|---|
| Installed Nginx package | 1.31.2-r1 to 1.31.8-r1 |
| Original Nginx configuration files compared | 19; all hashes match |
| Configuration ownership and permissions | Identical |
| Application file-tree hash | Identical |
| Node / PHP / runtime user | Unchanged |
| Candidate nginx -t | Exit 0 |
| Candidate isolated static request | HTTP 200 |
| Full application/DB and ARM runtime tests | Not performed |

## Hashes and method

Sorted Nginx file-checksum manifest SHA-256:

`92a22cae7dae52fbaea23a266b5071e1f6fcacbb808da71955fb79f09cfe6e69`

Application checksum-stream SHA-256, identical in both images:

`69bbd5aef1edbae4c52691a9d613aa95258df12da97f56050a3d12695b6b3c06`

These describe file inventories, not a guarantee of exploit resistance. The application checksum stream was computed with:

```sh
find /var/www/html -type f -exec sha256sum {} \; | sort | sha256sum
```

The Nginx manifest uses the same per-file procedure over /etc/nginx, without the final hash until the sorted output is captured. Ownership and permissions were compared separately.

[Machine-readable summary](validation.json) · [Build recipe](Dockerfile) · [Isolated test](smoke-test.sh)

Copyright 2026 mtalavi. Apache-2.0.
