# Example Notes

Installing an example node (test container with a webserver) [Minikube example]

- `kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.39 -- /agnhost netexec --http-port=8080`
- `kubectl expose deployment hello-node --type=LoadBalancer --port=8080`
- If you are using minikube, type: 
  - `minikube service hello-node`
  - You will see the results in your browser.
- If you are using a standard kubernetes cluster, type:  
  - `kubectl get services --sort-by=.metadata.name`
    - Make sure to note the under the Ports column (i.e. 8080:30727/TCP), the number you are concern about is the '30727', if the External-IP column is NOT '<pending>' you can use that address.
    - Otherwise, first determine which node the pod is running on (i.e. node01), type:
      - `kubectl get pods -o wide`
      - Type the command below, and use the address in the INTERNAL-IP (i.e. 172.30.1.2) for the node the pod is running on (i.e. node01).
        - `kubectl get nodes -o wide`
      - To see the output from the pod (this will have to be updated for your environment you are running based on the instruction above), type: 
        - `curl http://172.30.1.2:30727; echo`
      - This should display something like: `NOW: 2024-06-28 16:53:48.499882314 +0000 UTC m=+131.488826297`
- If you want to scale the deployment, first type the command below to see the status
  - `kubectl get deployments`

Removing example node

- `kubectl delete service hello-node`
- `kubectl delete deployment hello-node`

##  Installing the node-problem-detector

Installing the node-problem-detector

- `kubectl apply -f https://k8s.io/examples/debug/node-problem-detector.yaml`

Checking the node-problem-detector

- `kubectl get pods -n kube-system node-problem-detector`[press Tab to finish]
- `kubectl describe pod -n kube-system node-problem-detector`[press Tab to finish]
- `kubectl logs -n kube-system node-problem-detector`[press Tab to finish

Removing the node-problem-detector

- `kubectl delete daemonset node-problem-detector-v0.1 -n kube-system]`

## Installing a failed pod

- `kubectl apply -f kubernetes/testfail.yaml`

Deleting the failed pod

- `kubectl delete pod test-fail-exitcode`

## Running a Test DockerFile

- `vim Dockerfile`

Contents of the Dockerfile

```
FROM ubuntu:latest
# Install essential utilities (optional)
RUN apt update && apt install -y --no-install-recommends busybox
# Define the main process (background command)
CMD ["sleep", "inf"]
```
- `docker build --tag dockerfile -f Dockerfile .`
- `docker run -d --name running_container dockerfile`
- `docker ps`

Deleting the running container

- `docker stop running_container`
- `docker rmi dockerfile -f`
- `docker rm running_container`

