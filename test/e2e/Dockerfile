FROM alpine:3@sha256:fa1b3b8cd12d2b2ded5ef366f99b5a7556884646af680404989d626535a3ac14

ARG KUBECTL_VERSION="v1.36.1"
ARG HELM_VERSION="v4.2.0"
RUN apk add bash bind-tools \
    aws-cli \
    && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -P /usr/local/bin/ && chmod +x /usr/local/bin/kubectl \
    && wget -O - https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
