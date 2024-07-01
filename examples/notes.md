# Example Notes

Installing an example node and exposing a load balancer (test container with a webserver) [Minikube example]

- Method 1
  - `kubectl create deployment hello-node --image=registry.k8s.io/e2e-test-images/agnhost:2.39 -- /agnhost netexec --http-port=8080`
  - `kubectl expose deployment hello-node --name=loadbalancer --type=LoadBalancer --port=8080`
- Method 2
  - kubectl create deploy nginx --image=nginx:latest
  - kubectl expose deployment nginx --port=80 --name=nginxloadbalancer --type=LoadBalancer
- kubectl describe pod hello-node-<press Tab>
- kubectl describe deployment hello-node
- If you are using minikube, type: 
  - `minikube service hello-node`
  - You will see the results in your browser.
- If you are using a standard kubernetes cluster, type:  
  - `kubectl get services -o wide --sort-by=.metadata.name`
    - Make sure to note the under the **Ports** column (i.e. **8080:30727/TCP**), the number you are concern about is the **31026**, if the **External-IP** column is NOT **<pending>** you can use that address.
```
NAME           TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)...
loadbalancer   LoadBalancer   xx.xxx.xxx.xxx   aaaaaaaaa     xx:31026/TCP...
                                                                ^^^^^
```
    - Otherwise, first determine which **NODE** the pod is running on (i.e. node01), type:
      - `kubectl get pods -o wide`
```
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE...
hello-node-7694c-z7ch2   1/1     Running   0          17s   192.168.1.4   node01...
                                                                          ^^^^^^
```
      - Type the command below, and use the address in the **INTERNAL-IP** (i.e. **172.30.2.2**) for the node the pod is running on (i.e. **node01**).
        - `kubectl get nodes -o wide`
```
NAME           STATUS   ROLES           AGE   VERSION   INTERNAL-IP...
node01         Ready    <none>          xxx   vx.xx.x   172.30.2.2...
                                                        ^^^^^^^^^^
```
      - To see the output from the pod (this will have to be updated for your environment you are running based on the instruction above), type: 
        - `curl http://172.30.2.2:31026; echo` (Syntax: `curl -s http://<node-INTERNAL-IP:servicePORT>; echo`)
      - This should display something like: `NOW: 2024-06-28 16:53:48.499882314 +0000 UTC m=+131.488826297`
- If you want to scale the deployment, first type the command below to see the status
  - `kubectl get deployments`
- Method 1:
  - `kubectl scale deployment nginx --replicas=4`
- Method 2: 
  - `kubectl edit deployment nginx`
    - Change 'replicas:' to '1', press ESC and type ':x'
- `kubectl get pods -o wide`

Cleaning up deployment and service
- `kubectl delete service hello-node`
- `kubectl delete deployment hello-node`

##  Installing The node-problem-detector

Installing the node-problem-detector

- `kubectl apply -f https://k8s.io/examples/debug/node-problem-detector.yaml`

Checking the node-problem-detector

- `kubectl get pods -n kube-system node-problem-detector`[press Tab to finish]
- `kubectl describe pod -n kube-system node-problem-detector`[press Tab to finish]
- `kubectl logs -n kube-system node-problem-detector`[press Tab to finish

Removing the node-problem-detector

- `kubectl delete daemonset node-problem-detector-v0.1 -n kube-system]`

## Installing a Failed Pod

- `curl -s https://raw.githubusercontent.com/ubergeek316/kubecheck/main/examples/testfail.yaml -o testfail.yaml`
- `kubectl apply -f kubernetes/testfail.yaml`

Deleting the failed pod

- `kubectl delete pod test-fail-exitcode`

## Creating a Namespace

- kubectl create namespace demonstration
- Create the file below using the heredoc
```
cat << EOF >  resourcesquota.yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: demonstration
spec:
  soft:
    requests.cpu: "1"
    requests.memory: 1Gi
    limits.cpu: "2"
    limits.memory: 2Gi
EOF
```
- kubectl get namespaces
- kubectl describe namespaces demonstration
- kubectl apply -f resourcesquota.yaml -n demonstration
- kubectl create deploy nginx --image=nginx:latest -n demonstration
- kubectl get deployments.apps -n demonstration
- kubectl describe deployments.apps -n demonstration nginx
- kubectl get pods -n demonstration
- kubectl get events -n demonstration
Clean up resources
- kubectl delete deployment nginx -n demonstration
- kubectl delete namespaces demonstration

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

