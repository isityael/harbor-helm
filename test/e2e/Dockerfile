FROM alpine:3@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

ARG KUBECTL_VERSION="v1.36.1"
ARG HELM_VERSION="v4.2.0"
RUN apk add bash bind-tools \
    aws-cli \
    && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -P /usr/local/bin/ && chmod +x /usr/local/bin/kubectl \
    && wget -O - https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
