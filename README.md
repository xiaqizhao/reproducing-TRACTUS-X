# ReadMe

The purpose of this repository is to reproduce the [TRACTU-X project](https://github.com/eclipse-tractusx/tutorial-resources/blob/main/mxd/README.md). It documents the process of reproduction within the repository.

## Prerequisites

Assuming we have a Linux computer with Debian 12 that has just been set up, we still need:

> 1. Go == 1.16+
> 2. Docker
> 3. Local Kubernetes runtime: [kind](https://kind.sigs.k8s.io/)
> 4. gnupg, software-properties-common, curl
> 5. Terraform
> 6. ……
>
> Actually, there are few infrastructural dependencies that are not mentioned in the offical documents(Or maybe it's because we're pure rookies). We try to collocate the complete an dependencies list and robust automatical shell. 

This repository provides a shell script `Prerequisites.sh` to automatically set up the environment described above. The script is designed for users running Debian 12 and using zsh (tested environment). A setup.sh script is then provided to automate the deployment project.

