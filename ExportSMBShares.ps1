##########################################
##                                      ##
## Script: ExportSmbShares.ps1          ##
## Autor:  Leandro Pinheiro             ##
## Ver:    1.0 (202210190745)           ##
##                                      ##
##########################################

## Variaveis

$hostname = $(hostname)

## Mensagem Inicial

Write-Host "`r`nEste Script vai exportar todos os compartilhamentos SMB não administrativos do host: " -ForegroundColor Green -NoNewline
Write-Host "$($hostname)`r`n" -ForegroundColor Yellow 
Write-Host "Os arquivos " -ForegroundColor Green -NoNewline
Write-Host "$($hostname)-ExportShares.txt " -ForegroundColor Yellow -NoNewline
Write-Host "e " -ForegroundColor Green -NoNewline
Write-Host "$($hostname)-CreateShares.ps1" -ForegroundColor Yellow 
Write-Host "serão criados ao final da execução deste script na pasta atual.`r`n" -ForegroundColor Green

## Exportando SMB Shares

Write-Host "Exportando SMB Shares e criando o arquivo " -ForegroundColor Green -NoNewline
Write-Host "$($hostname)-ExportShares.txt" -ForegroundColor Yellow -NoNewline
Write-Host ": " -ForegroundColor Green -NoNewline

Write-Host "." -ForegroundColor White -NoNewline

Get-WmiObject -ComputerName $(hostname) -Class win32_share | Out-File -FilePath .\$($hostname)-ExportShares.txt

Write-Host " Feito!`r`n" -ForegroundColor Cyan

## Exportando Permissoes

Write-Host "Exportando as Permissoes dos SMB Shares não Administativos: " -ForegroundColor Green -NoNewline

$shares = Get-WmiObject -ComputerName $(hostname) -Class win32_share -Filter "Description != 'Remote Admin' and Description != 'Default share' and Description != 'Remote IPC' and Description != 'Printer Drivers' and Description != 'Administração remota' and Description != 'Recurso compartilhado padrão' and Description != 'IPC remoto'" | Select-Object Name,Path -ExpandProperty Name

Write-Host "." -ForegroundColor White -NoNewline

foreach ($share in $shares) {
	Write-Host "." -ForegroundColor White -NoNewline
	
	get-smbshareaccess -name $share  | Out-File -FilePath .\$($hostname)-ExportShares.txt -Append
}

Write-Host " Feito!`r`n" -ForegroundColor Cyan

Write-Host "Conteúdo do Arquivo $($hostname)-ExportShares.txt:`r`n" -ForegroundColor Green

Get-Content .\$($hostname)-ExportShares.txt

## Criando Script

Write-Host "Criando o Script PS1 " -ForegroundColor Green -NoNewline
Write-Host "$($hostname)-CreateShares.ps1" -ForegroundColor Yellow -NoNewline
Write-Host ": " -ForegroundColor Green -NoNewline

Write-Host "." -ForegroundColor White -NoNewline

"##############################################" | Out-File -FilePath .\$($hostname)-CreateShares.ps1
"##                                          ##" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append
"## Script: $($hostname)-CreateShares.ps1 ##" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append
"## Gerado: ExportSMBShares.ps1              ##" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append
"## Rev:    $(get-date -Format "yymmddhhmm")                       ##" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append
"##                                          ##" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append
"##############################################`r`n" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append

foreach ($share in $shares) {
	Write-Host "." -ForegroundColor White -NoNewline
		
	$permissions = Get-SmbShareAccess -Name $share.Name
	$UsersFull = @()
	$UsersRead = @()
	
	Write-Host $share.Path
	
	foreach ($permission in $permissions) {
		Write-Host "." -ForegroundColor White -NoNewline
		
		if ($permission.AccessRight -eq "Full") {
			$UsersFull += $permission.AccountName
		}
		
		if ($permission.AccessRight -eq "Read") {
			$UsersRead += $permission.AccountName
		}
	}
	
	$UsersFull = $UsersFull -join ""","""
	$UsersRead = $UsersRead -join ""","""
	
	"New-SmbShare -Name ""$($share.Name)"" -Path ""$($share.Path)"" -FullAccess ""$($UsersFull)"" -ReadAccess ""$($UsersRead)""`r`n" | Out-File -FilePath .\$($hostname)-CreateShares.ps1 -Append
}

Write-Host " Feito!`r`n" -ForegroundColor Cyan

Write-Host "Conteúdo do Arquivo $($hostname)-CreateShares.ps1:`r`n" -ForegroundColor Green

Get-Content .\$($hostname)-CreateShares.ps1

## Finalizando

Write-Host "`r`nScript Concluido.`r`n" -ForegroundColor Green
