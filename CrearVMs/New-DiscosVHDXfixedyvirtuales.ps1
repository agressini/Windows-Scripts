[CmdletBinding()]

param (
   
    [Parameter(Mandatory = $True)]
        [string] $pathvms,
        [string] $pathlista
       
)

begin {
    Write-Verbose "Se estan generando los discos virtuales aguarde..." -Verbose
    Write-Verbose "Espere a que el proceso termine." -Verbose
    Write-Verbose ""
    Write-Verbose "Creando las Carpetas" -Verbose

}

process {

    #Obtengo los valores de la lista
    $Get = Import-Csv $pathlista
   
    #creo las carpetas
    foreach ($element in $get ) {

        $pathVM= $pathvms+$element.VM 
        New-Item -Path "$($pathVM)" -ItemType Directory
        $pathDisks= $pathVM+"\"+$element.Name 
        New-Item -Path "$($pathDIsks)" -ItemType Directory
                
        #creando los discos virtuales vhdx fixed
        $Size=($element.Size/1gb)*1gb
        $pathDisk=$pathDisks+"\"+$element.Name+".vhdx" 
        New-VHD -Path $pathDisk -Fixed -SizeBytes $Size

        #Creo las maquinas virtuales
        $Ram=($element.Ram / 1gb) *1gb
        $createVM=Get-Vm -Name $element.VM 
        if($createVM.Name -ne $element.VM)
        {
            New-VM -Name $element.VM -Generation 2 -MemoryStartupBytes $Ram -Path $pathVM -SwitchName $element.NetworkAdapter
            Set-VM -Name $element.VM -ProcessorCount $element.CPU
            Add-VMDvdDrive -VMName $element.VM -Path $element.pathiso
            Add-VMHardDiskDrive -VMName $element.VM -ControllerType SCSI -Path $pathDisk 
        }
        else 
        {
            Add-VMHardDiskDrive -VMName $element.VM -ControllerType SCSI -Path $pathDisk 
        }
              
        
    } # foreach

    
} 

end 
{
    Write-Verbose ""
    Write-Verbose "Se termino la creacion de los Discos VHDX" -Verbose
    Write-Verbose "Se encuentran en la carpeta $pathvms" -Verbose
    Write-Verbose ""
}