# https://github.com/anchore/grype/blob/main/Dockerfile
# FROM anchore/grype:latest

FROM alpine:latest

WORKDIR /grype

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN apk add --no-cache \
     tar \
     zstd \
     curl \
     bash

RUN curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sh -s -- -b /usr/local/bin

# This will make grype not update database automatically, and fail if the age of the database is more than the default of 5 days (120 hours).
# See also https://github.com/anchore/grype#data-staleness
ENV GRYPE_DB_AUTO_UPDATE=false
ENV GRYPE_DB_MAX_ALLOWED_BUILT_AGE=120h

ENV GRYPE_DB_CACHE_DIR=/grype/db/

RUN /usr/local/bin/grype db update \
    && tar --use-compress-program "zstd -9 -T0" -cvpf grype-db.tar.zst db/ \
    && rm -rf db/

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
