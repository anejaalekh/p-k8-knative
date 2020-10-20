# p-k8-knative 

This repo contains terrform scripts to create VM on Azure. This repo contains following files

1. main.tf  -> This file is used to create resource group, virtual networks, network security group and virtual network peering across different regions. Vnet-peering is required for communication across regions. 
2. master.tf -> This file is used to create master node. This file creates virtual machine, public ip and other things needed for connections. This file will also install k8s stuff needed for master node as well. This script will also install hey and go as well
3. worker<num>.tf -> This file is used to create worker node. This file creates virtual machine, public ip and join this node to k8 cluser using master VM ip. Master node ip is mentioned under "provisioner" as 10.1.04. This script will install hey and go as well

Note: Currently only 1 worker file for each region is added here. Files can be easily replicated by changing we details. Working on automating this using script. 
Note: To add go in your class path 'export PATH=$PATH:/usr/local/go/bin'

# Steps to create k8 cluster on Azure
Prerequisite terraform should be installed(https://www.terraform.io/downloads.html)

1. terraform init
2. terrform plan
3. terraform apply 

Above mentioned commands will create a azure k8 cluster. terraform init will intialize the provider. terraform plan command will let you know if you run these scripts what will be the impact of the commands like what will be created, modified or destroyed. Terraform apply will create the infra on your azure account. Terraform will ask for confirmation before executing the commands.

Once you are done with your stuff, you can destroy the infra created using 'terraform destroy' command or you can east delete resource groups created using main.tf and that will delete all the resources as well.


# Install knative-serving

1. sudo bash
2. kubectl apply --filename https://github.com/knative/serving/releases/download/v0.18.0/serving-crds.yaml
3. kubectl apply --filename https://github.com/knative/serving/releases/download/v0.18.0/serving-core.yaml

# Install Istio
1. curl -L https://istio.io/downloadIstio | sh -
2. cat << EOF > ./istio-minimal-operator.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      proxy:
        autoInject: enabled
      useMCP: false
      jwtPolicy: first-party-jwt

  addonComponents:
    pilot:
      enabled: true
    prometheus:
      enabled: false

  components:
    ingressGateways:
      - name: istio-ingressgateway
        enabled: true
      - name: cluster-local-gateway
        enabled: true
        label:
          istio: cluster-local-gateway
          app: cluster-local-gateway
        k8s:
          service:
            type: ClusterIP
            ports:
            - port: 15021
              targetPort: 15021
              name: status-port
            - port: 80
              name: http2
              targetPort: 8080
            - port: 443
              name: https
              targetPort: 844
EOF
3. istioctl manifest install -f istio-minimal-operator.yaml  --set values.gateways.istio-ingressgateway.runAsRoot=true
4. kubectl get pods --namespace istio-system   (wait for pods status to be Running)
5. kubectl get svc -nistio-system
6. kubectl label namespace knative-serving istio-injection=enabled  (enable side car proxy)
7. kubectl apply --filename https://github.com/knative/net-istio/releases/download/v0.18.0/release.yaml


# Install autoscaler-go
 
 
  1. git clone -b "master" https://github.com/knative/docs knative-docs
  
  2. cd knative-docs/docs/serving/autoscaling/autoscale-go/
  
  3. kubectl apply -f service.yaml
  
  4. 'kubectl get all'  and find the autoscaler-service-ip to use in hey command to send load. Use the service with 'private' in its name. In the below o/p the autoscaler-service-ip is '10.110.131.84'
  
  
  NAME                                                READY   STATUS    RESTARTS   AGE
pod/autoscale-go-8n6fb-deployment-d99f6c989-rzppv   2/2     Running   0          11s

NAME                                 TYPE           CLUSTER-IP      EXTERNAL-IP                                            PORT(S)                             AGE
service/autoscale-go                 ExternalName   <none>          cluster-local-gateway.istio-system.svc.cluster.local   80/TCP                              2s
service/autoscale-go-8n6fb           ClusterIP      10.97.193.13    <none>                                                 80/TCP                              11s
service/autoscale-go-8n6fb-private   ClusterIP      10.110.131.84   <none>                                                 80/TCP,9090/TCP,9091/TCP,8022/TCP   11s
service/kubernetes                   ClusterIP      10.96.0.1       <none>                                                 443/TCP                             3h23m
5. to send request below mwntioned command can be used. Just replace the ip you have with 10.110.131.84.
 curl "http://10.110.131.84:80?sleep=100&prime=10000&bloat=5"


# Send Requests using hey

Terraform scripts will install hey and go to send requests to autocaler pod

1. sudo bash
2. cd ~/adminuser/hey
3. export PATH=$PATH:/usr/local/go/bin
4. go build
5. ./hey -z 15m -c 600 "http://<autoscaler-service-ip>:80?sleep=100&prime=10000&bloat=5" 


