[CmdletBinding()]
Param(
   [Parameter(Mandatory=$True,Position=0,HelpMessage="caminho do codigo fonte")]
   [string]$sourcerootfolder,
   
   [Parameter(Mandatory=$True,Position=1,HelpMessage="nome do modulo usado para compor a pasta de publicacao e arquivo zip")]
   [string]$appname,

   [Parameter(Mandatory=$True,Position=2,HelpMessage="tipo de deploy (lib, appweb ou appnet ")]
   [string]$typeapp,

   [Parameter(Mandatory=$True,Position=3,HelpMessage="arquivos array das pasta bin que serao enviados")]
   [string[]]$keepbinfiles

)

$ErrorActionPreference = 'Stop'

#$publishrootfolder = 'c:\pst\destino'
$publishrootfolder = 'c:\sse\work\jks\release\' + $appname  +  '\drop'
#$publishrootfolder = 'c:\sse\work\jks\dev\genericdao\drop'


Write-host 'source:' $sourcerootfolder
Write-host 'publish:' $publishrootfolder
Write-host 'aplicacao:' $appname
Write-host 'tipoaplicacao:' $typeapp
Write-host 'keppbinfiles:' $keepbinfiles


function ZIP-AppLib($SourceFolder,$PubRootFolder,$Sistema,$KeepBINFiles)
{
    
    try 
    {
        #Verificando a pasta de publicacao
        if(Test-Path $PubRootFolder)
        {
            #Apagar dados gerados de geracao anterior 
            $FilesPubRootFolder = $PubRootFolder + '\*.*'
            Write-Host 'Excluindo arquivos build anterior'  $FilesPubRootFolder
            Remove-Item $FilesPubRootFolder            
            #Copiar os arquivos gerados no pasta source
            Write-Host 'Copiando arquivos de' $SourceFolder 'para' $PubRootFolder
            Copy-Item $SourceFolder $PubRootFolder -Force -Recurse
            #Verificar restrição de arquivos definidos para o pacote 
            $FolderBIN = $PubRootFolder + '\bin'
            $FolderBINExclusao = $FolderBin + '\*.*'
            Write-Host 'Excluindo os arquivos da pasta' $FolderBINExclusao 'mantendo os arquivos' $KeepBINFiles
            Remove-Item $FolderBINExclusao -Exclude $KeepBINFiles 
            #Gerar o arquivo zip 
            $ZipFile = $PubRootFolder + '\' + $Sistema + '.zip'
            Write-Host 'Gerando o arquivo ZIP' $ZipFile
            Compress-ZIPFile $FolderBIN $ZipFile $True 
            #Remover os arquivos desnecessários
        
                Foreach($ItemRootExclusao in (Get-ChildItem $PubRootFolder -Recurse -File))
                { 
                    if($ZipFile -ne $ItemRootExclusao.FullName)
                    {
                        Write-Host 'Removendo o arquivo' $ItemRootExclusao.FullName
                        Remove-Item $ItemRootExclusao.FullName 
                    }
                }
                Foreach($ItemRootExclusao in (Get-ChildItem $PubRootFolder -Directory))
                { 
                    Write-Host 'Removendo o diretorio' $ItemRootExclusao.FullName
                    Remove-Item $ItemRootExclusao.FullName -Recurse 
                }
                exit 0         
        }
        else 
        {
          Write-Host 'Caminho de publicacao informado incorretamente' $PubRootFolder
          exit 1
          return  
        }

    }
    catch [Exception]
    {
        Write-Host 'ERRO NA EXECUCAO DO SCRIPT:' $_.Exception.Message
        exit 1 
        return 
    }      
}


function ZIP-AppWeb($SourceFolder,$PubRootFolder,$Sistema,$KeepBINFiles)
{
	
    try 
    {
        #Verificando a pasta de publicacao
        if(Test-Path $PubRootFolder)
        {
            #Apagar dados gerados de geracao anterior 
            $FilesPubRootFolder = $PubRootFolder + '\*.*'
            Write-Host 'Excluindo arquivos build anterior'  $FilesPubRootFolder
            Remove-Item $FilesPubRootFolder 
            $FolderApp = $SourceFolder           
            #Verificar restrição de arquivos definidos para o pacote 
            $FolderBINExclusao = $FolderApp + '\bin\*.*'
            Write-Host 'Excluindo os arquivos da pasta' $FolderBINExclusao 'mantendo os arquivos' $KeepBINFiles
            Remove-Item $FolderBINExclusao -Exclude $KeepBINFiles 
            #Gerar o arquivo zip 
            $ZipFile = $PubRootFolder + '\' + $Sistema + '.zip'
            Write-Host 'Gerando o arquivo ZIP' $ZipFile
            Compress-ZIPFile $FolderApp $ZipFile $False
            #Remover os arquivos desnecessários
        
                Foreach($ItemRootExclusao in (Get-ChildItem $PubRootFolder -Recurse -File))
                { 
                    if($ZipFile -ne $ItemRootExclusao.FullName)
                    {
                        Write-Host 'Removendo o arquivo' $ItemRootExclusao.FullName
                        Remove-Item $ItemRootExclusao.FullName 
                    }
                }
                Foreach($ItemRootExclusao in (Get-ChildItem $PubRootFolder -Directory))
                { 
                    Write-Host 'Removendo o diretorio' $ItemRootExclusao.FullName
                    Remove-Item $ItemRootExclusao.FullName -Recurse 
                }
                exit 0         
        }
        else 
        {
          Write-Host 'Caminho de publicacao informado incorretamente' $PubRootFolder
          exit 1
          return  
        }

    }
    catch [Exception]
    {
        Write-Host 'ERRO NA EXECUCAO DO SCRIPT:' $_.Exception.Message
        exit 1 
        return 
    }      
}



function ZIP-AppModuloNet($SourceFolder,$PubRootFolder,$Sistema,$KeepBINFiles)
{
    
	try 
    {
        #Verificando a pasta de publicacao
        if(Test-Path $PubRootFolder)
        {
            #Apagar dados gerados de geracao anterior  
            $FilesPubRootFolder = $PubRootFolder + '\*.*'
            Write-Host 'Excluindo arquivos build anterior'  $FilesPubRootFolder
            Remove-Item $FilesPubRootFolder 
            $FolderNet = $PubRootFolder + '\portalnet'
            $FolderBinNetPages = $SourceFolder +  '\bin'
            #Movendo a pasta bin para a pasta portalnet 
            Write-Host "Movendo a pasta bin" ($FolderBinNetPages) "para o diretorio " ($FolderNet)
            Move-Item $FolderBinNetPages $FolderNet 
            #Verificar restrição de arquivos definidos para o pacote 
            $FolderBINExclusao = $FolderNet + '\bin\*.*'
            Write-Host 'Excluindo os arquivos da pasta' $FolderBINExclusao 'mantendo os arquivos' $KeepBINFiles
            Remove-Item $FolderBINExclusao -Exclude $KeepBINFiles 
            #Gerar o arquivo zip 
            $ZipFile = $PubRootFolder + '\' + 'portalnet.zip'
            Write-Host 'Gerando o arquivo ZIP' $ZipFile
            $FolderBINExclusao = $PubRootFolder + '\bin'
            Compress-ZIPFile $FolderNet $ZipFile $False
            #Remover os arquivos desnecessários
        
                Foreach($ItemRootExclusao in (Get-ChildItem $PubRootFolder -Recurse -File))
                { 
                    if($ZipFile -ne $ItemRootExclusao.FullName)
                    {
                        Write-Host 'Removendo o arquivo' $ItemRootExclusao.FullName
                        Remove-Item $ItemRootExclusao.FullName 
                    }
                }
                Foreach($ItemRootExclusao in (Get-ChildItem $PubRootFolder -Directory))
                { 
                    Write-Host 'Removendo o diretorio' $ItemRootExclusao.FullName
                    Remove-Item $ItemRootExclusao.FullName -Recurse 
                }
                exit 0         
        }
        else 
        {
          Write-Host 'Caminho de publicacao informado incorretamente' $PubRootFolder
          exit 1
          return  
        }

    }
    catch [Exception]
    {
        Write-Host 'ERRO NA EXECUCAO DO SCRIPT:' $_.Exception.Message
        exit 1 
        return 
    }      
}




function Extract-ZIPFile($SourceFolderZip, $DestFolderZip)
{
    Add-Type -AssemblyName "system.io.compression.filesystem"
    [io.compression.zipfile]::ExtractToDirectory((Get-ChildItem $SourceFolderZip)[0].FullName, $DestFolderZip) 
}
function Compress-ZIPFile($FolderToZip, $PathFileZip,$IncluirDir)
{
    Add-Type -AssemblyName "system.io.compression.filesystem"
    [io.compression.zipfile]::CreateFromDirectory($FolderToZip, $PathFileZip, "optimal", $IncluirDir) 
}


if ($typeapp -eq "lib")
{
    ZIP-AppLib $sourcerootfolder $publishrootfolder $appname $keepbinfiles
}
elseif ($typeapp -eq "appweb")
{
    ZIP-AppWeb $sourcerootfolder $publishrootfolder $appname $keepbinfiles
}
elseif ($typeapp -eq "appnet")
{
    ZIP-AppModuloNet $sourcerootfolder $publishrootfolder $appname $keepbinfiles
}
else
{
  Write-Host "Tipo de Aplicacao nao implementada:" ($typeapp)
  exit 1 
}