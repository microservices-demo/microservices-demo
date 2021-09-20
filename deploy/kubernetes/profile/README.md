# Profile for deploying Microservices demo helm chart


The microservices-demo profile command can be installed using [pctl](https://github.com/weaveworks/pctl).

Please review the pctl documents [here](https://profiles.dev/)

The profile can be installed with the following command.

```
pctl add --name microservices-demo \
    --namespace default \
    --profile-branch master \
    --profile-repo-url https://github.com/microservices-demo/microservices-demo.git \ --profile-path ./deploy/kubernetes/profile \
    --git-repository flux-system/flux-system
```