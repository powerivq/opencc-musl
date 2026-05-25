# opencc-musl

Builds a musl/Alpine-compatible OpenCC runtime artifact for USCC101 WordPress.

The artifact is a tarball, not a single binary, because OpenCC needs runtime
configuration and dictionary files such as `s2tw.json`, `s2hk.json`, and `*.ocd2`.
It also includes the upstream experimental Jieba segmentation plugin so the
WordPress image can use `s2tw_jieba.json` and `s2hk_jieba.json`.

## Artifacts

For OpenCC `1.3.1`, releases should publish:

- `opencc-1.3.1-alpine-amd64.tar.gz`
- `opencc-1.3.1-alpine-amd64.tar.gz.sha256`
- `opencc-1.3.1-alpine-arm64.tar.gz`
- `opencc-1.3.1-alpine-arm64.tar.gz.sha256`

Each tarball extracts into:

```text
bin/opencc
lib/opencc/plugins/libopencc-jieba.so
share/opencc/*.json
share/opencc/*.ocd2
share/opencc/jieba_dict/*
```

The Jieba-backed configs are:

- `share/opencc/s2t_jieba.json`
- `share/opencc/s2tw_jieba.json`
- `share/opencc/s2hk_jieba.json`
- `share/opencc/s2twp_jieba.json`
- `share/opencc/tw2sp_jieba.json`

Runtime callers should set:

```sh
export OPENCC_DATA_DIR=/usr/local/share/opencc
export OPENCC_SEGMENTATION_PLUGIN_PATH=/usr/local/lib/opencc/plugins
```

`OPENCC_DATA_DIR` makes config/resource lookup deterministic. `OPENCC_SEGMENTATION_PLUGIN_PATH`
makes plugin lookup deterministic after the tarball is extracted into `/usr/local`.

## Local Build

Build one architecture:

```sh
./scripts/build-artifact.sh amd64
./scripts/build-artifact.sh arm64
```

Build both release artifacts:

```sh
./scripts/build-all.sh
```

For arm64 on an amd64 machine, Docker Buildx and QEMU must be configured.

## Upstream Version Tracking

The project tracks upstream tags from `BYVoid/OpenCC`.

Check manually:

```sh
./scripts/check-upstream-version.sh
```

The scheduled `check upstream OpenCC` GitHub workflow runs weekly. If a newer
`ver.*` tag exists upstream, it opens an issue labeled `upstream-opencc`.

Release workflow inputs:

- `opencc_version`: version without the `ver.` prefix, for artifact naming.
- `opencc_ref`: optional upstream git ref/tag/SHA. Defaults to `ver.<version>`.
- `release_tag`: this repo's release tag, for example `1.3.1`.

## Consume From WordPress Alpine Image

```Dockerfile
ARG TARGETARCH
ARG OPENCC_VERSION=1.3.1
ARG OPENCC_RELEASE=1.3.1
RUN set -eux; \
    case "$TARGETARCH" in \
      amd64) opencc_arch=amd64 ;; \
      arm64) opencc_arch=arm64 ;; \
      *) echo "unsupported OpenCC arch: $TARGETARCH" >&2; exit 1 ;; \
    esac; \
    apk add --no-cache libstdc++; \
    curl -fsSL -o /tmp/opencc.tar.gz \
      "https://github.com/powerivq/opencc-musl/releases/download/${OPENCC_RELEASE}/opencc-${OPENCC_VERSION}-alpine-${opencc_arch}.tar.gz"; \
    tar -C /usr/local -xzf /tmp/opencc.tar.gz; \
    rm -f /tmp/opencc.tar.gz; \
    export OPENCC_DATA_DIR=/usr/local/share/opencc; \
    export OPENCC_SEGMENTATION_PLUGIN_PATH=/usr/local/lib/opencc/plugins; \
    opencc --version; \
    echo '汉字 银行 优惠 开户奖励' | opencc -c /usr/local/share/opencc/s2tw.json; \
    echo '汉字 银行 优惠 开户奖励' | opencc -c /usr/local/share/opencc/s2hk.json; \
    echo '汉字 银行 优惠 开户奖励' | opencc -c /usr/local/share/opencc/s2tw_jieba.json; \
    echo '汉字 银行 优惠 开户奖励' | opencc -c /usr/local/share/opencc/s2hk_jieba.json
```

## Jieba Notes

OpenCC's Jieba plugin is upstream's first external C++ segmentation plugin.
It is useful when max-match segmentation chooses poor boundaries, but it is
still marked experimental upstream. The artifact packages the plugin exactly
as built from OpenCC, without patching cppjieba dictionaries.

Site-specific terminology still belongs in the WordPress conversion override
layer. For example, upstream `s2hk_jieba.json` currently converts `开户奖励`
to `開户獎勵`, so USCC101 must still override financial vocabulary after
OpenCC conversion.
