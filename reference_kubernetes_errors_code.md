Following is the list of official Kubernetes pod errors with error descriptions.

---|---|
Pod Error Type | Error Description |
ErrImagePull | If kubernetes is not able to pull the image mentioned in the manifest. |
ErrImagePullBackOff | Container image pull failed, kubelet is backing off image pull |
ErrInvalidImageName | Indicates a wrong image name. |
ErrImageInspect | Unable to inspect the image. |
ErrImageNeverPull | Specified Image is absent on the node and PullPolicy is set to NeverPullImage. |
ErrRegistryUnavailable | HTTP error when trying to connect to the registry |
ErrContainerNotFound | The specified container is either not present or not managed by the kubelet, within the declared pod. |
ErrRunInitContainer | Container initialization failed. |
ErrRunContainer | Pod’s containers don’t start successfully due to misconfiguration. |
ErrKillContainer | None of the pod’s containers were killed successfully. |
ErrCrashLoopBackOff | A container has terminated. The kubelet will not attempt to restart it. |
ErrVerifyNonRoot | A container or image attempted to run with root privileges. |
ErrCreatePodSandbox | Pod sandbox creation did not succeed. |
ErrConfigPodSandbox | Pod sandbox configuration was not obtained. |
ErrKillPodSandbox | A pod sandbox did not stop successfully. |
ErrSetupNetwork | Network initialization failed. |
ErrTeardownNetwork | n/a |
--|--|
