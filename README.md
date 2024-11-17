# Automated Deployment of Keycloak and PostgreSQL on Azure using Terraform and Ansible

This project provides the creation of a virtual machine (VM) in Azure Cloud, set up with a minimal container environment. The environment hosts a Keycloak container, a PostgreSQL database, and a web server serving a static webpage. Access to the web page is controlled by Keycloak for authentication. The infrastructure is defined and deployed using Terraform and configuration management is handled through Ansible.

## Key Features
- **Azure VM Setup**: Provisioning of a virtual machine in Azure using Terraform.
- **Keycloak Deployment**: Containerized Keycloak for authentication and user management.
- **PostgreSQL Database**: A Postgres database for storing user data and other relevant information.
- **Static Web Page**: A web server serving a static page protected by Keycloak authentication.
- **Infrastructure as Code**: Terraform for infrastructure management and Ansible for configuration automation.
- **CI/CD Pipeline**: GitHub Actions used for deploying, configuring, and destroying the project.

## License
This project is licensed under the MIT License - see the [https://creativecommons.org/licenses/by-nc/4.0/deed.en](LICENSE) file for details.