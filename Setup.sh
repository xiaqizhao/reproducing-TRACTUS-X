#!/bin/zsh

cd ~/workspace4TRACTUS
git clone https://github.com/eclipse-tractusx/tutorial-resources.git
cd ./tutorial-resources/mxd
kind create cluster -n mxd --config kind.config.yaml
# the next step is specific to KinD and will be different for other Kubernetes runtimes!
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
# wait until the ingress controller is ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

cd ../mxd-runtimes
./gradlew dockerize
kind load docker-image --name mxd data-service-api tx-identityhub tx-identityhub-sts tx-identityhub tx-catalog-server tx-sts

cd ../mxd
terraform init
terraform apply

# type "yes" and press enter when prompted to do so
# alternatively execute terraform apply -auto-approve