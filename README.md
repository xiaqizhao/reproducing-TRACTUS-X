# ReadMe
The purpose of this repository is to reproduce the [TRACTU-X project](https://github.com/eclipse-tractusx/tutorial-resources/blob/main/mxd/README.md). It documents the process of reproduction within the repository.

## Prerequisites
Assuming we have a Linux computer with Debian 12 that has just been set up, we still need:
1. Go == 1.16+
2. Docker
3. Local Kubernetes runtime: [kind](https://kind.sigs.k8s.io/)
4. gnupg, software-properties-common, curl
5. Terraform

This repository provides a shell script `Prerequisites.sh` to automatically set up the environment described above. The script is designed for users running Debian 12 and using zsh (tested environment).