# Layers a go2rtc build with native Reolink Baichuan support onto Frigate's
# published image, replacing the stock go2rtc binary Frigate's own
# docker/main/install_go2rtc.sh installs at /usr/local/go2rtc/bin/go2rtc.
#
# Native Baichuan support (the `reolink://` stream scheme) comes from an
# unmerged go2rtc PR (AlexxIT/go2rtc#2263), head fzurita/go2rtc@reolink_protocol.
# Pinned to a commit, not the branch head, since the branch will keep moving.
# Bump GO2RTC_COMMIT manually if the PR is updated; see README.md.
FROM golang:1.24-alpine AS go2rtc-build
RUN apk add --no-cache git
ARG GO2RTC_COMMIT=a30b9d3f1a10e75431529151f291ea0d96668bf7
RUN git clone https://github.com/fzurita/go2rtc.git /src \
    && cd /src && git checkout ${GO2RTC_COMMIT}
WORKDIR /src
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -trimpath -o /go2rtc .

FROM ghcr.io/blakeblackshear/frigate:0.18.2
COPY --from=go2rtc-build /go2rtc /usr/local/go2rtc/bin/go2rtc
