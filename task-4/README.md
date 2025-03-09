# Task 4: Network Security

## Objective: Secure a Kubernetes Cluster on AWS

### Implementing Cluster Network Security with IAM Roles and Policies

#### Setting Up IAM for Kubernetes Access

1. **Connect IAM Roles to Kubernetes Pods**:
   
   This allows pods to securely access AWS services without storing credentials:

   ```bash
   # Enable IAM roles for service accounts on your cluster
   eksctl utils associate-iam-oidc-provider --cluster=my-cluster --approve
   
   # Create a service account with specific permissions
   eksctl create iamserviceaccount \
     --name app-service-account \
     --namespace default \
     --cluster my-cluster \
     --attach-policy-arn arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess \
     --approve
   ```

2. **Follow the Principle of Least Privilege**:
   
   Only give the exact permissions needed for each component:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Action": [
           "ecr:GetDownloadUrlForLayer",
           "ecr:BatchGetImage"
         ],
         "Resource": "arn:aws:ecr:us-west-2:123456789012:repository/my-app"
       }
     ]
   }
   ```

3. **Secure the Kubernetes Control Plane**:
   
   Make your cluster's API server private:

   ```bash
   # Make the API server private
   aws eks update-cluster-config \
     --name my-cluster \
     --region us-west-2 \
     --resources-vpc-config endpointPrivateAccess=true,endpointPublicAccess=false
   ```

4. **Manage Who Can Access the Cluster**:
   
   Map AWS IAM users and roles to Kubernetes permissions:

   ```bash
   # Give an admin user access to the cluster
   eksctl create iamidentitymapping \
     --cluster my-cluster \
     --arn arn:aws:iam::123456789012:user/admin-user \
     --group system:masters \
     --username admin
   ```

### Network Security Best Practices

#### Control Communication Between Pods

Use network policies to decide which pods can talk to each other:

```yaml
# Block all traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: production
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

```yaml
# Allow frontend to talk to backend only
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - protocol: TCP
      port: 8080
```

#### Set Up AWS Security Groups

Control traffic at the EC2 instance level:

```bash
# Create a security group for worker nodes
aws ec2 create-security-group \
  --group-name EKS-Workers \
  --description "Security group for EKS workers" \
  --vpc-id vpc-12345

# Allow nodes to communicate with each other
aws ec2 authorize-security-group-ingress \
  --group-id sg-12345 \
  --protocol all \
  --source-group sg-12345
```

#### Setting Up Firewalls and VPNs

1. **Use AWS Network Firewall**:
   
   Add an extra layer of protection for your network traffic:

   ```bash
   # Create a firewall policy
   aws network-firewall create-firewall-policy \
     --firewall-policy-name EKS-Protection \
     --firewall-policy file://basic-policy.json
   
   # Deploy the firewall
   aws network-firewall create-firewall \
     --firewall-name EKS-Firewall \
     --firewall-policy-arn arn:aws:network-firewall:policy \
     --vpc-id vpc-12345 \
     --subnet-mappings SubnetId=subnet-12345
   ```

2. **Set Up VPN Access**:
   
   Secure way for team members to access the cluster:

   ```bash
   # Create a VPN endpoint
   aws ec2 create-client-vpn-endpoint \
     --client-cidr-block 10.0.0.0/22 \
     --server-certificate-arn arn:aws:acm:certificate \
     --authentication-options Type=certificate-authentication,MutualAuthentication={ClientRootCertificateChainArn=arn:aws:acm:client-cert}
   
   # Connect VPN to your network
   aws ec2 associate-client-vpn-target-network \
     --client-vpn-endpoint-id cvpn-endpoint-12345 \
     --subnet-id subnet-12345
   ```

### Additional Key Security Measures

1. **Manage Secrets Properly**:
   
   Use AWS Secrets Manager instead of storing secrets in your code or configs:

   ```bash
   # Install the necessary components
   helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver \
     --namespace kube-system
   kubectl apply -f aws-provider-installer.yaml
   ```

2. **Encrypt Your Kubernetes Secrets**:
   
   Add an extra layer of protection:

   ```bash
   # Create an encryption key
   aws kms create-key --description "Key for encrypting K8s secrets"
   
   # Enable encryption on the cluster
   aws eks update-cluster-config \
     --name my-cluster \
     --encryption-config '[{"resources":["secrets"],"provider":{"keyArn":"arn:aws:kms:key"}}]'
   ```

3. **Scan Container Images for Vulnerabilities**:
   
   Check images for security issues before deploying:

   ```bash
   # Turn on automatic scanning
   aws ecr put-image-scanning-configuration \
     --repository-name my-app \
     --image-scanning-configuration scanOnPush=true
   ```

4. **Run Regular Security Checks**:
   
   ```bash
   # Run a security benchmark test
   kubectl apply -f kube-bench-job.yaml
   
   # Check the results
   kubectl logs job/kube-bench
   ```

By implementing these security measures, you'll have a well-protected Kubernetes cluster on AWS that follows security best practices while remaining manageable.