<#
A script is meant to copy a managed disk to a storage account and then later on can be used as unmanaged disk for a VM
The managed disk should be unattached to be able to copy it to a storage account
#>

$ResourceGroupName = "[ResourceGroupName]"
$ManagedDiskName = "[ManagedDiskName].vhd"
$StorageAccountName = "[StorageAccountName]"
$StorageAccountAccessKey = "[StorageAccountAccessKey]"
$ContainerName = "[ContainerName]"
$VHDName = "[NameOfVhdFileToBeCreated].vhd"

$sub = Login-AzAccount -ErrorAction Stop
    if($sub){
        Get-AzSubscription| Out-GridView -PassThru -Title "Select your Azure Subscription" |Select-AzSubscription
        
    }

$ManagedDiskSas = Grant-AzDiskAccess -ResourceGroupName $ResourceGroupName -DiskName $ManagedDiskName -DurationInSecond 3600 -Access Read
$DestStorageAcctContext = New-AzStorageContext –StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountAccessKey
$blobcopy = Start-AzStorageBlobCopy -AbsoluteUri $ManagedDiskSas.AccessSAS -DestContainer $ContainerName -DestContext $DestStorageAcctContext -DestBlob $VHDName

while(($blobCopy | Get-AzStorageBlobCopyState).Status -eq "Pending")
{
    Write-Host "Managed Disk $ManagedDiskName is still being copied to $($destStorageAcctContext.BlobEndPoint)$ContainerName/$VHDName" -ForegroundColor Yellow
    Start-Sleep -s 30
    $blobCopy | Get-AzStorageBlobCopyState
}