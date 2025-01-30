# gke-cluster-terraform
This setup creates a fully functional GKE cluster with monitoring tools (Prometheus and Grafana) deployed using Helm.

1. Install Required Tools
a) Install Terraform
•	Download Terraform from the official website.
•	Extract the binary and add it to your system's PATH.
•	Verify installation:
# terraform –version

b) Install Google Cloud SDK
•	Download and install the Google Cloud SDK.
•	Initialize and authenticate:
# gcloud init
# gcloud auth login
Verify installation:
# gcloud –version

c) Install kubectl
Install kubectl (Kubernetes CLI) using Google Cloud SDK:
# gcloud components install kubectl

Verify installation:
# kubectl version –client

d) Install Helm 
Install Helm for managing Kubernetes applications:
•	Download Helm from the official website.
•	Add Helm to your PATH.
•	Verify installation:

# helm version

2. Set Up Google Cloud Credentials
a) Create a Service Account
•	Go to the GCP Console.
•	Navigate to IAM & Admin > Service Accounts.
•	Create a new service account with the required permissions (e.g., Editor role).
•	Generate a JSON key for the service account and download it.
b) Set Environment Variable for Credentials
•	Set the path to the service account JSON key as an environment variable in PowerShell:

$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\path\to\your\service-account-key.json"

3. Configure Terraform for GCP
a) Create a Terraform Configuration File
•	Create a main.tf file with your GCP cluster configuration (e.g., the one you provided earlier).
b) Initialize Terraform
•	Navigate to the directory containing your main.tf file and run:

# terraform init
# terraform validate
# terraform plan
# terraform apply
