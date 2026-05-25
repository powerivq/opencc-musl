# syntax=docker/dockerfile:1.7
FROM alpine:3.20 AS builder

ARG OPENCC_VERSION=1.3.1
ARG OPENCC_REF=ver.${OPENCC_VERSION}
ARG TARGETARCH

RUN apk add --no-cache \
    build-base \
    cmake \
    git \
    ninja \
    python3

RUN git clone --depth 1 --branch "${OPENCC_REF}" https://github.com/BYVoid/OpenCC.git /src/opencc

WORKDIR /src/opencc

RUN cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/opencc \
    -DBUILD_SHARED_LIBS=OFF \
    -DBUILD_DOCUMENTATION=OFF \
    -DBUILD_TESTING=OFF \
 && cmake --build build \
 && cmake --install build

RUN mkdir -p /out/bin /out/share/opencc \
 && cp /opt/opencc/bin/opencc /out/bin/opencc \
 && cp -R /opt/opencc/share/opencc/. /out/share/opencc/ \
 && chmod +x /out/bin/opencc \
 && test -f /out/share/opencc/s2tw.json \
 && test -f /out/share/opencc/s2hk.json

FROM alpine:3.20 AS runtime

RUN apk add --no-cache libstdc++
COPY --from=builder /out/bin/opencc /usr/local/bin/opencc
COPY --from=builder /out/share/opencc /usr/local/share/opencc

ENV OPENCC_VERSION=${OPENCC_VERSION}

RUN opencc --version \
 && printf '%s\n' '汉字 银行 优惠 开户奖励' | opencc -c /usr/local/share/opencc/s2tw.json \
 && printf '%s\n' '汉字 银行 优惠 开户奖励' | opencc -c /usr/local/share/opencc/s2hk.json

FROM scratch AS artifact
COPY --from=builder /out /
