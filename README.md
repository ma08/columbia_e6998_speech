<!-- omit in toc -->
# E6998 Fundamentals of Speech Recognition (Prof. Homayoon Beigi) at Columbia University

This repository contains information to setup a Ubuntu 20.04 VM Google Cloud VM and install Kaldi on it for the `E6998 Fundamentals of Speech Recognition` course at Columbia University in the City of New York.

<!-- omit in toc -->
## Contents
- [Redeem Google Cloud Credits](#redeem-google-cloud-credits)
- [Create Google Project](#create-google-project)
- [Install `Google Cloud CLI`](#install-google-cloud-cli)
- [Increase GPU Quota](#increase-gpu-quota)
    - [GPU WARNING - IMPORTANT](#gpu-warning)
- [Create VM](#create-vm)
- [SSH to VM](#ssh-to-vm)
    - [Generate SSH Key](#generate-ssh-key)
    - [Add SSH key to VM Metadata](#add-ssh-key-to-vm-metadata)
    - [Start SSH session](#start-ssh-session)
        - [Native SSH client](#native-ssh-client)
        - [Using gcloud command](#ssh-using-gcloud)
- [Install Dependencies](#install-dependencies)
- [Install GPU Drivers](#install-gpu-drivers)
- [Install Kaldi](#install-kaldi)
    - [Check Dependencies](#check-dependencies)
    - [Installation](#installation)
- [Test GPU for Kaldi](#test-gpu-for-kaldi)
- [Remove GPU - IMPORTANT](#remove-gpu---important)
- [Google Cloud SSH and GPU tips](#google-cloud-ssh-and-gpu-tips)
- [Contribute](#contribute)



### Redeem Google Cloud Credits
You must be receiving a coupon for redeeming Google Cloud Credits from the TA. Once you have the coupon, use [these instructions](https://cloud.google.com/billing/docs/how-to/edu-grants#redeem) to redeem.

### Create Google Project
Please create a new project for smoother configuration using [these instructions](https://developers.google.com/workspace/guides/create-project).
- Use a relevant name for the project like `Speech-Rec-E6998`.
- Make sure that the billing account is set to `Billing Account for Education` which you get from redeeming the cloud credits from the previous step.


### Install `Google Cloud CLI`
This is not strictly necessary in my experience but good to have to do operations on Google Cloud from the command line than webpage GUI. Follow the [installation instructions](https://cloud.google.com/sdk/docs/install-sdk#installing_the_latest_version) and the [initializing instructions](https://cloud.google.com/sdk/docs/install-sdk#initializing_the).


### Increase GPU Quota
[Instructions to increase GPU quota](https://stackoverflow.com/questions/53415180/gcp-error-quota-gpus-all-regions-exceeded-limit-0-0-globally) for the project. When making the request, you could mention the reason to raise the limit could be something along the lines of needing GPU to run experiments for Fundamentals of Speech Recognition coursework at Columbia.

Generally you need to wait for a few minutes to get the approval email. Once approved, proceed to the next steps.

#### GPU WARNING
In the following steps, we will create a VM with GPU, install Nvidia CUDA drivers and test it with kaldi. We are creating the GPU only to test it. Make sure to follow step to remove the GPU from the configuration of VM after installing and testing the drivers.



### Create VM
1. Go to [VM instances page](https://console.cloud.google.com/compute/instances). Make sure that the right project is selected. 
2. If asked to enable `Compute Engine API`, enable it.  
3. Create a VM with the following config and a suitable name (for e.g. `speech-spring23`)
   - OS: `Ubuntu 20.04 (x86/64)`
   - Type: `n1-highmem-8` (8 vCPUs, 52GB GB memory)
   - CPU Platform: `Intel Haswell`
   - GPUs: `1 x NVIDIA Tesla K80`
   - Zone: `us-east1-c`
   - Boot disk and local disks: `1.2 TB (Type: Standard persistent disk)`. MAKE SURE TO CHANGE FROM THE DEFAULT TYPE.
  
### SSH to VM
While you can use the in-browser SSH session provided by Google Cloud, it is strongly advised to SSH from the terminal on your local machine. The in-browser SSH has some issues, it generally gets killed automatically after a while.

#### Generate SSH Key
Follow [these instructions](https://cloud.google.com/compute/docs/connect/create-ssh-keys#create_an_ssh_key_pair) to generate the SSH key from your local machine. For the `KEY_FILENAME` and `USERNAME`, make sure to use YOUR UNI. Therefore, you need to run the following command, replacing `<UNI>` with your own UNI:
   - $ `ssh-keygen -t rsa -f ~/.ssh/<UNI> -C <UNI> -b 2048`
  
For example if UNI is `sk5057`. The command would be:
   - $ `ssh-keygen -t rsa -f ~/.ssh/sk5057 -C sk5057 -b 2048`

Your public key file is saved to `~/.ssh/<UNI>.pub`. You will need this in the next step.

#### Add SSH key to VM Metadata
Follow [these instructions](https://cloud.google.com/compute/docs/connect/add-ssh-keys#after-vm-creation)
1. Go to your VM page
2. Click `Edit` (need not stop VM to do this)
3. Under `SSH Keys`, click `Add item`.
4. Add the contents of your public key at `~/.ssh/<UNI>.pub` into the text box. Ensure that the contents of the key are properly copied w.r.t the spaces else you might get an error.
5. Save

#### Start SSH session
##### Native SSH client
You can use the default SSH command on your system using [these instructions](https://cloud.google.com/compute/docs/connect/ssh-using-third-party-tools#connect_to_vms).
- Get External IP Address of your VM from [the VM instances page](https://console.cloud.google.com/compute/instances) of your project.
- Run the following command by replace <UNI> and <External IP> with yours:
  - $ `ssh -i ~/.ssh/<UNI> <UNI>@<External IP>`
  - For example: $ `ssh -i ~/.ssh/sk5057 sk5057@35.211.220.122`

I generally prefer to use the above approach.
##### SSH using `gcloud`
Refer to [examples and documentation here](https://cloud.google.com/sdk/gcloud/reference/compute/ssh) to SSH using the `gcloud compute ssh` command.

Generally the following works:
  - $ `gcloud compute ssh <VM NAME> --ssh-key-file=~/.ssh/<UNI> --zone=<ZONE NAME>   --project=<PROJECT NAME>`
  - For example: $ `gcloud compute ssh speech-spring-23 --ssh-key-file=~/.ssh/sk5057 --zone=us-east1-c --project=Speech-Rec-E6998`

### Install Dependencies
Run the [kaldi_prerequisites](kaldi_prerequisites.sh) script to install the dependencies for kaldi.
-  $ `./kaldi_prerequisites.sh`

### Install GPU Drivers
Run the [install_cuda_driver.sh](install_cuda_drivers.sh) script to install CUDA. This should generally work fine, if not, read the file to go through the references and commands to debug.
- $ `./install_cuda_drivers.sh` 

Check installation by running
- $ `nvidia-smi`

### Install Kaldi
#### Check Dependencies
1. $ `cd kaldi-trunk/tools/`
2. $ `extras/check_dependencies.sh`
3. Depending upon the output from above you might need to install `mkl`, `unzip`, and `fortran`. Install as required. Example commands for the above three
   - $ `./extras/install_mkl.sh`
   - $ `sudo apt-get install unzip gfortran`
#### Installation
Run the following commands:
1. $ `cd ~/kaldi-trunk/tools/`
2. $ `make -j 8`
3. $ `cd ../src`
4. $ `./confiugre`
5. $ `make depend -j 8`
6. $ `make -j 8`
 
### Test GPU for Kaldi
If all of the above commands run successfully, kaldi is successfully installed! Finally, we want to check if the GPU and CUDA setup is working well for kaldi as this is the main source of trouble generally.

Run the following command to test
- $ `~/kaldi-trunk/src/nnet3bin/cuda-gpu-available`

If successful, you should get the following command

## Remove GPU - IMPORTANT
If you configure a GPU, even when you are not using it, you are
quickly depleting your credits and credits are limited.

Therefore, PLEASE REMOVE THE GPU after testing the CUDA installation.
- Stop the VM
- Edit
- Go to CPUs and remove GPUA
- Save (Don't forget this!)

## Google Cloud SSH and GPU tips
Refer to [this file](SSH_and_GPU.md) for solutions to common SSH and GPU problems. Make sure to read this file. 





