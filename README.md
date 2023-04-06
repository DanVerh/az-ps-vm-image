# Azure VM Image creation
This repository is the Azure Poweshell script that is creating a VM Image from existing Virtual Machine and creates a new one from that image.

1. Manually create a VM and configure it.
2. Go to Azure CLI Powershell or execute the code directly from your system after running `az login` (or `az account set --subscription mysubscription` if required).
3. `generalize.ps1` is used to generalize a VM using a sysprep.
4. `image.ps1` will trigger `generalize.ps1`, create an Azure Image Gallery, which Image will be placed in, and create a new VM from that image.

*Note: be really careful while using this script, because original VM, that image is created from, will be generalized*
