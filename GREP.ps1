$id = Read-Host -Prompt 'Prompt'

if ($id = '') {
} else {
    :condition for($x=1; $x -lt 6; $x=$x+1)   { 
        $path = "E:\Leaks\Facebook_RF\Data\France\France 0$x.txt"
        Write-Host "[~] $path" -ForegroundColor yellow
        foreach($line in [System.IO.File]::ReadLines("$path")) { 
            if($line -like "*$id*"){
                Write-Host "[+] FOUND : $line" -ForegroundColor green
                Write-Host "`nTerminating script."
                Break condition
            }
        }
    }
}