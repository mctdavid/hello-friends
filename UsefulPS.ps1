#Create SPN and secret
az ad sp create-for-rbac --name amsrspn --years 2

#Curl Command for Splunk
curl -k https://*.azure.com:8088/services/collector -H 'Authorization: Splunk 0fd45ee8-1ddc-41bb-b033-63fb63577d44' -d '{"sourcetype": "mysourcetype", "event":"Hello, World!"}'

---------------Build Web Sever---------------------------
$resourcegroup = "deleteanytimeRG"
$location = "west us"

New-AzureRmResourceGroup -Name $resourcegroup -Location $location

$storageaccountname = "deleteanytimestrg"
New-AzureRmStorageAccount -name $storageaccountname -ResourceGroupName $resourcegroup -Type Standard_LRS -Location $location

$vnetname = "deleteanytimevnet"
$subnet = New-AzureRmVirtualNetworkSubnetConfig -name frontendsubnet -AddressPrefix 10.0.1.0/24
$vnet = New-AzureRmVirtualNetwork -Name $vnetname -ResourceGroupName $resourcegroup -Location $location -AddressPrefix 10.0.0.0/16 -Subnet $subnet

$nicname = "vm1-nic"
$pip = New-AzureRmPublicIpAddress -Name $nicname -ResourceGroupName $resourcegroup -Location $location -AllocationMethod Dynamic

$nic = New-AzureRmNetworkInterface -Name $nicname -ResourceGroupName $resourcegroup -Location $location -SubnetId $vnet.Subnets[0].Id `
                                    -PublicIpAddressId $pip.Id

$vmname = "deletewin-web"
$vm = New-AzureRmVMConfig -VMName $vmname -VMSize "Basic_A1"

$cred = Get-Credential -Message "Admin credentials"
$vm= Set-AzureRmVMOperatingSystem -VM $vm -Windows -ComputerName $vmname -Credential $cred -ProvisionVMAgent -EnableAutoUpdate

$vm= Set-AzureRmVMSourceImage -VM $vm -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2012-R2-Datacenter" -Version "latest"

$vm= Add-AzureRmVMNetworkInterface -VM $vm -Id $nic.Id

$diskname= "os-disk"
$storageacc= Get-AzureRmStorageAccount -ResourceGroupName $resourcegroup -Name $storageaccountname
$osdiskuri= $storageacc.PrimaryEndpoints.Blob.ToString() + "vhds/" + $diskname + ".vhd"
$vm=Set-AzureRmVMOSDisk -VM $vm -Name $diskname -VhdUri $osdiskuri -CreateOption FromImage                             

New-AzureRmVM -ResourceGroupName $resourcegroup -Location $location -VM $vm

----------------------------------------------Check User------------------------------------------------
Get-AzureRmSubscription | foreach-object {
   Write-Verbose -Message "Changing to Subscription $($_.Name)" -Verbose
   set-azurermcontext -SubscriptionId $_.SubscriptionId   
if(Get-AzureRmRoleAssignment -SignInName edmondr@anyname.com) {
write-host "user exist"
} Else {
Write-Host "user does not exist"
}
}
-------------------------

