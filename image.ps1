#Use this script carefully, because it does sysprep in your VM and generalizes it

Write-Host "Script for creating an image from VM and new VM from this image `n" -BackgroundColor DarkBlue

#Set variables for the vm, that image will be taken from
Write-Host "Source VM" -ForegroundColor Yellow
$location = Read-Host "Location "
$rgName = Read-Host "RG "
$vmName = Read-Host "VM Name "
$imageName = Read-Host "Name for Image "
$vm = Get-AzVM -ResourceGroupName $rgName -Name $vmName
$disk = Get-AzDisk -ResourceGroupName $rgName -DiskName $vm.StorageProfile.OsDisk.Name

#Set variables for the vm, that will be created from image
Write-Host ""
Write-Host "VM from Image" -ForegroundColor Yellow
$vnetName = Read-Host "VNet "
$subnetName = Read-Host "Subnet Name "
$imageVmName = Read-Host "Name for New VM "
$sgName = Read-Host "Name for SG "
$pipName = Read-Host "Name for PIP "

#Execute script to remove Panther folder and do sysprep on the VM
Invoke-AzVMRunCommand -ResourceGroupName $rgName -VMName $vmName -CommandId 'RunPowerShellScript' -ScriptPath 'generalize.ps1'
#Set state of VM to generalized
Set-AzVm -ResourceGroupName $rgName -Name $vmName -Generalized

#Set image parameteres
$imageConfig = New-AzImageConfig `
   -Location $location
$imageConfig = Set-AzImageOsDisk `
   -Image $imageConfig `
   -OsState Generalized `
   -OsType Windows `
   -ManagedDiskId $disk.Id

#Create image
$image = New-AzImage `
   -ImageName $imageName `
   -ResourceGroupName $rgName `
   -Image $imageConfig

#Create Compute Gallery
$imageGallery = New-AzGallery `
   -GalleryName 'imageGallery' `
   -ResourceGroupName $rgName `
   -Location $location `

#Create Image Definition
$imageDefintion = New-AzGalleryImageDefinition `
   -GalleryName "imageGallery" `
   -ResourceGroupName $rgName `
   -Location $location `
   -Name 'myImageDefinition' `
   -OsState Generalized `
   -OsType Windows `
   -Publisher 'myPublisher' `
   -Offer 'myOffer' `
   -Sku 'mySKU'

#Create Image Version   
New-AzGalleryImageVersion `
   -ResourceGroupName $rgName `
   -GalleryName $imageGallery.Name `
   -GalleryImageDefinitionName $imageDefintion.Name `
   -Name 1.0.0 `
   -Location $location `
   -SourceImageId $image.Id

#Create VM from image
New-AzVm `
   -ResourceGroupName $rgName `
   -Name $imageVmName `
   -Image $image.Id `
   -Location $location `
   -VirtualNetworkName $vnetName `
   -SubnetName $subnetName `
   -SecurityGroupName $sgName `
   -PublicIpAddressName $pipName 