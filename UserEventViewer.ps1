# Code

# Description

# 0xC0000064	Account does not exist
# 0xC000006A	Incorrect password
# 0xC000006D	Incorrect username or password
# 0xC000006E	Account restriction
# 0xC000006F	Invalid logon hours
# 0xC000015B	Logon type not granted
# 0xC0000070	Invalid Workstation
# 0xC0000071	Password expired
# 0xC0000072	Account disabled
# 0xC0000133	Time difference at DC
# 0xC0000193	Account expired
# 0xC0000224	Password must change
# 0xC0000234	Account locked out

function Get-FailureReason {
  Param($FailureReason)
    switch ($FailureReason) {
      '0xC0000064' {"Account does not exist"; break;}
      '0xC000006A' {"Incorrect password"; break;}
      '0xC000006D' {"Incorrect username or password"; break;}
      '0xC000006E' {"Account restriction"; break;}
      '0xC000006F' {"Invalid logon hours"; break;}
      '0xC000015B' {"Logon type not granted"; break;}
      '0xc0000070' {"Invalid Workstation"; break;}
      '0xC0000071' {"Password expired"; break;}
      '0xC0000072' {"Account disabled"; break;}
      '0xC0000133' {"Time difference at DC"; break;}
      '0xC0000193' {"Account expired"; break;}
      '0xC0000224' {"Password must change"; break;}
      '0xC0000234' {"Account locked out"; break;}
      '0x0' {"0x0"; break;}
      default {"Other"; break;}
  }
}

$tries = 0
$user = Read-Host "[+] Usuario: "
while ($tries -lt 50) {
    try{
		Write-Output ''
		Write-Host '[..] Este proceso puede demorarse aproximadamente 1 minuto...'
		Write-Output ''
		$resultado = Get-WinEvent -FilterHashtable @{LogName = 'Security'; ID = 4625} -ComputerName {INGRESE EL HOSTNAME DE SU DC} -MaxEvents 15
		ForEach($result in $resultado){
			$time = $result.TimeCreated
			$result = $result | Select -ExpandProperty Message | Select-String $User		
			# $result
			$usuario = $result | Select-String -Pattern "[A-Z]{4}\d{4}" | Foreach-Object {$_.Matches} | Foreach-Object {$_.Groups[0].Value} #--> Cree una expresión regular para buscar por el usuario ingresado. En este ejemplo se busca: TEST0001
			$codigos = $result | findstr Status | Select-String -Pattern "0xC\w+" | ForEach-Object {$_.Matches} | ForEach-Object {$_.Groups[0].Value}
			if($usuario){
				Write-Host "`r`n[*] Nombre de usuario: $usuario"
				Write-Host "[*] Fecha: $time"	
				Write-Host "[*] Codigos de error encontrados: "				
				ForEach($codigo in $codigos){ Write-Host "		";Get-FailureReason($codigo);Write-Host "($codigo)" }
			}
		}
		$tries = 50

		Write-Output ''
        Read-Host " Presione Enter para cerrar..."
	}
	catch{
        Write-Host "[-] No se pudo conectar al servidor. Intentando nuevamente..."
    }
}
