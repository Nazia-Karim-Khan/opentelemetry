# Opentelemetry Setup

## Setup Instructions

### Step 1: Set Up K0s Cluster

```bash
k0sctl apply --config k0s/k0sctl.yaml --no-wait
k0sctl kubeconfig
```

### Step 2: Install Cilium

```bash
chmod +x cilium/install.sh
cilium install --version 1.16.1 --values cilium/cilium-values.yaml
```

### Step 3: Install OpenEBS

```bash
helm repo add openebs https://openebs.github.io/charts
helm repo update
helm install openebs openebs/openebs --namespace openebs --create-namespace
```

### Step 4: Install Grafana

```bash
kubectl create namespace grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install grafana grafana/grafana -f grafana/values.yaml --namespace grafana
```

To access Grafana if using ClusterIP:
```bash
kubectl port-forward svc/grafana -n grafana 5000:80
```

### Step 5: Install Distributed Loki

```bash
kubectl create namespace loki
helm install loki grafana/loki-distributed -f loki/values.yaml --namespace loki
```

### Step 6: Install Tempo

```bash
kubectl create namespace tempo
helm install tempo grafana/tempo-distributed -f tempo/values.yaml --namespace tempo
```

### Step 7: Install Mimir

```bash
kubectl create namespace mimir-test
helm show values grafana/mimir-distributed > mimir/values.yaml
helm install mimir grafana/mimir-distributed -f mimir/values.yaml --namespace mimir-test
```

### Step 8: Install Prometheus

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm show values prometheus-community/prometheus > prometheus/values.yaml
helm install prometheus prometheus-community/prometheus -n prometheus --create-namespace -f prometheus/values.yaml
helm upgrade prometheus prometheus-community/prometheus -n prometheus --create-namespace -f prometheus/values.yaml
```

### Step 9: Install OpenTelemetry Operator

```bash
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm install opentelemetry-operator open-telemetry/opentelemetry-operator \
  --set "manager.collectorImage.repository=otel/opentelemetry-collector-k8s" \
  --set admissionWebhooks.certManager.enabled=false \
  --set admissionWebhooks.autoGenerateCert.enabled=true \
  -n opentelemetry \
  --create-namespace
```

Later update the repository:

```bash
helm upgrade opentelemetry-operator open-telemetry/opentelemetry-operator \
  --set "manager.collectorImage.repository=otel/opentelemetry-collector-contrib" \
  --set admissionWebhooks.certManager.enabled=false \
  --set admissionWebhooks.autoGenerateCert.enabled=true \
  -n opentelemetry
```

### Step 10: Install OpenTelemetry Collector

Incorrect Installation:
```bash
helm install otel-collector open-telemetry/opentelemetry-collector \
  --namespace opentelemetry \
  --set image.repository="otel/opentelemetry-collector-k8s" \
  --values otel-collector.yaml
```

Correct Installation:
```bash
kubectl apply -f otel-collector.yaml -n opentelemetry
```

## References

- [Grafana Helm Charts](https://github.com/grafana/helm-charts/tree/main/charts)
- [Mimir Documentation](https://grafana.com/docs/helm-charts/mimir-distributed/latest/get-started-helm-charts/)
- [OpenTelemetry Helm Charts](https://github.com/open-telemetry/opentelemetry-helm-charts?tab=readme-ov-file)
- [OpenTelemetry Collector](https://grafana.com/docs/mimir/latest/configure/configure-otel-collector/)
- [Reddit Discussion on OpenTelemetry](https://www.reddit.com/r/OpenTelemetry/comments/1efmocv/cant_use_prometheusremotewrite_in_opentelemetry/?rdt=54991)
