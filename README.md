# docker-build-server

A simple Terraform file that provisions a GCE VM instance, automatically installs a Docker image of the latest version of Jenkins, and creates a firewall rule that opens it on port 8080. Right now the user still needs to SSH into the box, run the container, and grab the password from within the container before they can visit Jenkins on port 8080 and login. But I plan to automate this further, probably with Ansible or a Terraform provisioner.

Not an optimal approach if your goal is full automation, but still a good learning experience.

Reference:
https://github.com/hashicorp/terraform-provider-google/issues/1022#issuecomment-475383003

<h4>Prerequisites:</h4>
You must have a GCP project with billing enabled (or be on the free trial) with a service account created. The project must also have the default network provisioned.

<h4>Instructions:</h4>
From your Cloud Shell

    git clone https://github.com/jscottmatthews/docker-build-server
    cd docker-build-server
    gcloud iam service-accounts keys create key.json --iam-account=EMAIL_ACCT     
    **Note: EMAIL_ACCT = email account of the service account in your project 
    terraform init
    teraform plan 
    terraform apply
    
This will create the instance and firewall rules, and output the IP address. Save this, then SSH into the box and run the following commands to start the container and grab the password.

    docker run -d -p 8080:8080 jenkins/jenkins:lts-jdk11
    docker container ls 
    docker exec -it CONTAINER_ID /bin/bash
    cat /var/jenkins_home/secrets/initialAdminPassword

Now use the IP address from above to navigate to IP_ADDR:8080 and login with the password. 
