# explicitly use Debian for maximum cross-architecture compatibility
FROM debian:buster-slim AS compiler

RUN set -eux; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		ca-certificates \
		gnupg dirmngr \
		wget \
		\
		gcc \
		libc6-dev \
		make \
		\
		file \
	; \
	rm -rf /var/lib/apt/lists/*

# https://www.musl-libc.org/download.html
ENV MUSL_VERSION 1.1.24
RUN set -eux; \
	wget -O musl.tgz.asc "https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz.asc"; \
	wget -O musl.tgz "https://www.musl-libc.org/releases/musl-$MUSL_VERSION.tar.gz"; \
	\
	export GNUPGHOME="$(mktemp -d)"; \
	gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys '836489290BB6B70F99FFDA0556BCDB593020450F'; \
	gpg --batch --verify musl.tgz.asc musl.tgz; \
	gpgconf --kill all; \
	rm -rf "$GNUPGHOME" musl.tgz.asc; \
	\
	mkdir /usr/local/src/musl; \
	tar --extract --file musl.tgz --directory /usr/local/src/musl --strip-components 1; \
	rm musl.tgz

WORKDIR /usr/src/hello

COPY . .

RUN mkdir -p ./amd64/hello-world && \
	set -ex && \
	make clean all \
		TARGET_ARCH='amd64' \
		CROSS_COMPILE='x86_64-linux-gnu-'

RUN find \( -name 'hello' -or -name 'hello.txt' \) -exec file '{}' + -exec ls -lh '{}' +

CMD ["./amd64/hello-world/hello"]

FROM scratch
COPY --from=compiler /usr/src/hello/amd64/hello-world /
CMD ["/hello"]