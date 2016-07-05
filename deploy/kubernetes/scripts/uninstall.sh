
# Remove all deployments, will also remove pods
kubectl delete deployments --all

# Remove all services, except kubernetes
kubectl delete service $(kubectl get services | cut -d" " -f1 | grep -v NAME | grep -v kubernetes)