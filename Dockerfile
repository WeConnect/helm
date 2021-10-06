# Copyright The Helm Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM golang:1.11 AS builder
COPY . /go/src/k8s.io/helm
WORKDIR /go/src/k8s.io/helm
RUN apt-get update && apt install ca-certificates libgnutls30 -y
RUN go get github.com/golang/protobuf/proto
RUN make bootstrap
RUN make docker-binary


FROM alpine:3.7

RUN apk update && apk add ca-certificates socat && rm -rf /var/cache/apk/*

ENV HOME /tmp

COPY --from=builder /go/src/k8s.io/helm/rootfs/helm /helm
COPY --from=builder /go/src/k8s.io/helm/rootfs/tiller /tiller

EXPOSE 44134
USER 65534
ENTRYPOINT ["/tiller"]

