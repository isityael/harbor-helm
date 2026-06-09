FROM alpine:3@sha256:4f4ba248d8a2c90a6e52ffdfc194181f7617f9ddaca348d4c550a6b354fc7c2a

ARG KUBECTL_VERSION="v1.36.1"
ARG HELM_VERSION="v4.2.0"
RUN apk add bash bind-tools \
    aws-cli \
    && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -P /usr/local/bin/ && chmod +x /usr/local/bin/kubectl \
    && wget -O - https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
