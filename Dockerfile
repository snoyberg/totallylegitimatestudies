# Thanks Deni https://www.fpcomplete.com/blog/2017/12/building-haskell-apps-with-docker
FROM fpco/stack-build:lts-11 as build
RUN mkdir /opt/build
COPY app config src static studies templates test package.yaml stack.yaml /opt/build
RUN cd /opt/build && stack install --system-ghc --local-bin-path /opt/build/exe

FROM ubuntu:16.04
RUN mkdir -p /opt/app
WORKDIR /opt/app
RUN apt-get update && apt-get install -y \
  ca-certificates \
  libgmp-dev
COPY --from=build /opt/build/exe .
COPY --from=build /opt/build/static /opt/app/static
COPY config /opt/app/config
COPY studies /opt/app/studies
CMD ["/opt/app/totallylegitimatestudies"]
