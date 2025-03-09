# Task 3: Kubernetes Cluster Management

## Objective: Troubleshooting a Kubernetes Pod Repeatedly Crashing

### Investigating the Pod Crashing Issue

When a Kubernetes pod is repeatedly crashing, I would follow these systematic troubleshooting steps:

1. **Check Pod Status and Details**:
   ```bash
   # Get basic information about the problematic pod
   kubectl get pods -n <namespace>
   
   # Get detailed information about the pod
   kubectl describe pod <pod-name> -n <namespace>
   ```
   This will reveal the pod's current status, restart count, events, conditions, and any initialization or readiness issues.

2. **Examine Pod Logs**:
   ```bash
   # Get logs from the current pod instance
   kubectl logs <pod-name> -n <namespace>
   
   # Get logs from previous container instance if it crashed
   kubectl logs <pod-name> -n <namespace> --previous
   
   # If it's a multi-container pod, specify the container
   kubectl logs <pod-name> -c <container-name> -n <namespace>
   ```
   The logs often contain error messages, stack traces, or warnings that indicate the root cause.

3. **Check Kubernetes Events**:
   ```bash
   # Get all events in the namespace
   kubectl get events -n <namespace> --sort-by='.lastTimestamp'
   
   # Filter events related to the pod
   kubectl get events -n <namespace> --field-selector involvedObject.name=<pod-name>
   ```
   Events can show issues like image pull failures, resource constraints, or scheduling problems.

4. **Verify Resource Allocation and Limits**:
   ```bash
   # Check if the pod is hitting resource limits
   kubectl top pod <pod-name> -n <namespace>
   ```
   This helps identify if the pod is crashing due to resource constraints (OOMKilled).

5. **Check ConfigMaps and Secrets**:
   ```bash
   # List ConfigMaps being used
   kubectl get configmaps -n <namespace>
   
   # List Secrets being used
   kubectl get secrets -n <namespace>
   ```
   Verify if the pod has access to all required configuration and secrets.

6. **Inspect Node Status**:
   ```bash
   # Check node status where the pod is scheduled
   kubectl describe node <node-name>
   ```
   This helps identify node-level issues affecting the pod.

7. **Debugging with Temporary Pod**:
   ```bash
   # Create a debugging pod with the same image
   kubectl run debug-pod --image=<same-image-as-crashing-pod> --command -- sleep 1000
   kubectl exec -it debug-pod -- /bin/sh
   ```
   This allows testing the application environment directly.

8. **Review Deployment Specs**:
   ```bash
   kubectl get deployment <deployment-name> -n <namespace> -o yaml
   ```
   Check for misconfigurations in the deployment specification.

### Scaling Up a Deployment

To scale up a Kubernetes deployment and monitor its resource usage:

1. **Manual Scaling**:
   ```bash
   # Scale a deployment to desired number of replicas
   kubectl scale deployment <deployment-name> -n <namespace> --replicas=<number>
   ```

2. **Horizontal Pod Autoscaler (HPA)**:
   ```bash
   # Create an HPA
   kubectl autoscale deployment <deployment-name> -n <namespace> --min=2 --max=10 --cpu-percent=70
   
   # Check HPA status
   kubectl get hpa -n <namespace>
   ```
   
   HPA YAML example:
   ```yaml
   apiVersion: autoscaling/v2
   kind: HorizontalPodAutoscaler
   metadata:
     name: app-hpa
     namespace: <namespace>
   spec:
     scaleTargetRef:
       apiVersion: apps/v1
       kind: Deployment
       name: <deployment-name>
     minReplicas: 2
     maxReplicas: 10
     metrics:
     - type: Resource
       resource:
         name: cpu
         target:
           type: Utilization
           averageUtilization: 70
     - type: Resource
       resource:
         name: memory
         target:
           type: Utilization
           averageUtilization: 80
   ```

3. **Monitoring CPU and Memory Usage**:
   
   **Using kubectl**:
   ```bash
   # Monitor pod resource usage
   kubectl top pods -n <namespace>
   
   # Monitor node resource usage
   kubectl top nodes
   ```
   
   **Using Prometheus and Grafana**:
   - Deploy Prometheus using the Prometheus Operator with kube-prometheus
   - Set up Grafana dashboards for Kubernetes monitoring
   - Use the Kubernetes Dashboard for a visual interface
   
   **Example Prometheus monitoring setup**:
   ```bash
   # Install Prometheus Operator using Helm
   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring
   ```
   
   **Setting up metrics-server**:
   ```bash
   kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
   ```

### Using ArgoCD for GitOps Deployment

ArgoCD is a GitOps continuous delivery tool for Kubernetes that automates the deployment of applications:

1. **Installing ArgoCD**:
   ```bash
   # Create namespace for ArgoCD
   kubectl create namespace argocd
   
   # Apply ArgoCD manifests
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   
   # Access the ArgoCD UI
   kubectl port-forward svc/argocd-server -n argocd 8080:443
   ```

2. **Setting up an Application in ArgoCD**:
   ```yaml
   apiVersion: argoproj.io/v1alpha1
   kind: Application
   metadata:
     name: my-application
     namespace: argocd
   spec:
     project: default
     source:
       repoURL: https://github.com/organization/repository
       targetRevision: HEAD
       path: kubernetes/manifests
     destination:
       server: https://kubernetes.default.svc
       namespace: application-namespace
     syncPolicy:
       automated:
         prune: true
         selfHeal: true
       syncOptions:
       - CreateNamespace=true
   ```

3. **GitOps Workflow with ArgoCD**:
   - Developers commit changes to the Git repository
   - ArgoCD detects changes to the manifests in the repository
   - ArgoCD automatically applies those changes to the cluster
   - ArgoCD ensures the cluster state matches the desired state in Git

4. **ArgoCD Best Practices**:
   - Use application-specific repositories or directories
   - Implement role-based access control (RBAC) for ArgoCD
   - Use Kustomize or Helm for templating
   - Set up notifications for sync events and failures
   - Implement proper backup strategies for ArgoCD configurations

5. **Monitoring and Managing ArgoCD**:
   ```bash
   # Check status of all applications
   kubectl get applications -n argocd
   
   # Get detailed status of a specific application
   kubectl describe application my-application -n argocd
   
   # Using ArgoCD CLI
   argocd app list
   argocd app sync my-application
   ```

This GitOps approach ensures infrastructure changes are declarative, version-controlled, and automatically applied, significantly reducing manual intervention and potential for human error.