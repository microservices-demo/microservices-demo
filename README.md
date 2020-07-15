# Sock Shop : A Microservice Demo Application

This a fork of the demo (microsservices) application [Sock Shop](https://github.com/microservices-demo/microservices-demo). This fork is intended to demonstrate the use o autoscaling in a microservice application as part of an activity of the cource [IF1007](https://github.com/IF1007/if1007).

To do so, we followed the tutorial [How to Use Kubernetes for Autoscaling](https://dzone.com/articles/how-to-use-kubernetes-for-autoscaling) and part of the official [walkthrough](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/). Besisdes, we run a local kubernetes cluster locally by using Minikube to test the application and autoscaling.

## Requirements
Docker
Virtual Box
[Minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)
[kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Steps to Run the Application
To run the application, one needs to clone this repo, start Minikube e deploy the application on the (local) cluster.

To facilitate, a script (start_app.sh) was created and placed on the root of this repo.
The general steps to deploy the app can be found on the [Socker Shop docs](https://kubernetes.io/docs/tasks/tools/install-minikube/)

The script configures Minikube to run with 4608MB of memory and uses virtualbox as its driver.

## The Autoscaling Operation

The first step we set up was to set the limits and requests of the target service that was selected to be autoscaled.
The values set:
```yaml
resources:
          limits:
            cpu: 100m
            memory: 100Mi
          requests:
            cpu: 100m
            memory: 100Mi
```            
This can be found under /deploy/kubernetes/complete-demo.yaml (catalogue Deployment)

Another decision was to use the command line to config HPA, aiming not to polute too much the YAML and to be more versitile.
So, the HPA for the catalogue service can be set by running the following command:
```terminal
kubectl autoscale deployment catalogue --cpu-percent=50 --min=1 --max=10
```
To test the scaling, we decide to use the CPU as the metric of choice.

To check the current status of the autoscaler mechanism:
```terminal
kubectl get hpa
```
Just like the [tutorial](https://dzone.com/articles/how-to-use-kubernetes-for-autoscaling), we used the the [wrk tool](https://github.com/wg/wrk) by running it through a Docker container.


