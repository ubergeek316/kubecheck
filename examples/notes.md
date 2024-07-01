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

## Creating a Quota

~~- `kubectl create namespace demonstration`~~
- Create the file below using the heredoc

```
cat << EOF > pods-high.yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high
value: 10000  # Adjust the value based on your priority needs (higher = higher priority)
description: "High Priority Class for critical applications"
EOF
```

- Create the file below using the heredoc

```
cat << EOF > pods-high-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: high-priority
spec:
  containers:
  - name: high-priority
    image: ubuntu
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo hello; sleep 10;done"]
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "1Gi"
        cpu: "500m"
  priorityClassName: high
EOF
```

- `kubectl create -f pods-high.yaml`
- `kubectl describe quota`
- `kubectl create -f pods-high-pod.yaml`
- `kubectl describe quota`
~~- `kubectl get namespaces`~~
- `kubectl describe namespaces pods-high`
- `kubectl get quota -n pods-high`
~~- `kubectl create deploy nginx --image=nginx:latest -n pods-high`~~
- `kubectl get deployments.apps -n pods-high`
- `kubectl describe deployments.apps -n pods-high nginx`
- `kubectl get pods -n pods-high`
- `kubectl get events -n pods-high`
Clean up resources
- `kubectl delete deployment nginx -n demonstration`
- `kubectl delete namespaces demonstration`

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

## Rolling Update Example

- `vim nginx-test.yaml`
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 4
  selector:
    matchLabels:
      app: nginx
  minReadySeconds: 5
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.0
        ports:
        - containerPort: 80
        readinessProbe:
          initialDelaySeconds: 5
          successThreshold: 1
          httpGet:
            path: /
            port: 80
```
- `kubectl apply -f nginx-test.yaml --record`
  - The `--record` flag will serve a purpose in the rollback process.
- `kubectl describe deployments.apps nginx-deployment`
   - `Image: nginx:1.14.0`
Perform Rolling Update
- `kubectl set image deployment nginx-deployment nginx=nginx:1.14.2 --record`
- `kubectl describe deployments.apps nginx-deployment`
  - `Image: nginx:1.14.2`
Check Rollout Status
- `kubectl rollout status deployment nginx-deployment`
Pause and Resume Rolling Update
- `kubectl rollout pause deployment nginx-deployment`
- `kubectl rollout resume deployment nginx-deployment`
Rollback Changes
- `kubectl rollout history deployment nginx-deployment`
- `kubectl rollout undo deployment nginx-deployment --to-revision=1`
