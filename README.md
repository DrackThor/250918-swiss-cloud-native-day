# 250918-swiss-cloud-native-day

## build image

```shell
docker buildx build . \           
--platform linux/amd64 -t drackthor2/bern:latest
docker push drackthor2/bern:latest
```

## install cluster

```shell
cd kubespray
terraform -chdir=contrib/terraform/exoscale plan -var-file=../../../inventory/swiss-exoscale/terraform.tfvars
terraform -chdir=contrib/terraform/exoscale apply -var-file=../../../inventory/swiss-exoscale/terraform.tfvars
mv contrib/terraform/exoscale/inventory.ini inventory/swiss-exoscale/inventory.ini 

export ANSIBLE_HOST_KEY_CHECKING=False
ansible -i inventory/swiss-exoscale/inventory.ini -m ping all
ansible-playbook -b -i inventory/swiss-exoscale/inventory.ini cluster.yml


export KUBECONFIG=$(pwd)/inventory/swiss-exoscale/artifacts/admin.conf
kubectl --kubeconfig inventory/swiss-exoscale/artifacts/admin.conf get all -A


terraform -chdir=contrib/terraform/exoscale destroy -var-file=../../../inventory/swiss-exoscale/terraform.tfvars
```

## kube-bench

```shell
ssh ubuntu@<master-ip>
nerdctl run --pid=host \
  -v /etc:/etc:ro \
  -v /var:/var:ro \
  -v $(which kubectl):/usr/local/mount-from-host/bin/kubectl \
  -v ~/.kube:/.kube \
  -e KUBECONFIG=/.kube/config \
  -t docker.io/aquasec/kube-bench:latest \
  run --targets master

# or
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/refs/heads/main/job-node.yaml
kubectl apply -f https://raw.githubusercontent.com/aquasecurity/kube-bench/refs/heads/main/job-master.yaml
```

## openscap

```shell
# install openscap
ssh ubuntu@<master-ip>
apt-get update && apt-get install -y openscap-utils openscap-common openssh-client wget unzip vim

# get SSG
wget https://github.com/ComplianceAsCode/content/releases/latest/download/scap-security-guide-0.1.78.zip
unzip scap-security-guide-0.1.78.zip

# run scan
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_cis_level1_server \
    --report ubuntu-report.html \
    scap-security-guide-0.1.78/ssg-ubuntu2204-ds.xml

scp master-ip:/tmp/ubuntu-report.html . 
```

## cnspec

```shell
# run a remote scan
cnspec scan ssh ubuntu@159.100.242.105 --incognito --sudo --policy-bundle mondoo-linux-security.mql.yaml

cnspec scan ssh ubuntu@159.100.242.105 --incognito --sudo --policy-bundle mondoo-policy-CIS-Kubernetes-Benchmark---Level-1---Master-Node_2025-09-14_1757840930.mql.yaml

cnspec scan ssh ubuntu@159.100.242.105 --incognito --sudo --policy-bundle mondoo-kubernetes-security.mql.yaml

cnspec scan k8s --incognito --discover all --policy-bundle mondoo-kubernetes-best-practices.mql.yaml
```
