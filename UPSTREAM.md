# Upstream Tracking

This repository packages [BYVoid/OpenCC](https://github.com/BYVoid/OpenCC) for
Alpine/musl runtimes.

## Current Upstream

- OpenCC version: `1.3.1`
- Default upstream ref: `ver.1.3.1`

The Docker build accepts two inputs:

- `OPENCC_VERSION`: version used in artifact names.
- `OPENCC_REF`: upstream git ref/tag/SHA to build. Defaults to `ver.${OPENCC_VERSION}`.

## Checking For Updates

```sh
./scripts/check-upstream-version.sh
```

The scheduled GitHub workflow `check upstream OpenCC` runs weekly and opens an
issue if BYVoid/OpenCC publishes a newer `ver.*` tag.

## Updating

1. Check the latest upstream tag.
2. Run the `release` workflow with the new `opencc_version`.
3. Publish a new release tag such as `1.3.2`.
4. Update the consuming WordPress Dockerfile to the new release tag and SHA256s.
