$loop = $true
$scriptpath = $MyInvocation.MyCommand.Path
$scriptpath = $scriptpath -replace $MyInvocation.MyCommand.Name, ""
Set-Location $scriptpath

$host.UI.RawUI.ForegroundColor = "White"

Foreach ($i in $(Get-Content config.psd1)){
        Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
    }

While ($loop){
    Write-Host "   1 - Launch"
    Write-Host "   2 - Open config"
    Write-Host "   3 - Exit`n"
    $option = Read-Host -Prompt '     Input '

    if ($option -eq 2){
        Invoke-Item "./config.psd1"
    } elseif ($option -eq 1) {
        Foreach ($i in $(Get-Content config.psd1)){
            Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
        }
        $id = Read-Host -Prompt '     Search for '
        Write-Host ""
        Write-Host -NoNewLine "     OK! " -ForegroundColor green
        Write-Host -NoNewLine "Starting researches... (Research mode set to $RESEARCHMODE)"
        Write-Host ""
        Get-ChildItem -Path "$RESEARCHDIR*.txt" | ForEach-Object -Process { 
            Write-Host -NoNewLine "     ["
            Write-Host -NoNewLine "~" -ForegroundColor yellow
            Write-Host -NoNewLine "] $_"
            Write-Host ""
            foreach($line in [System.IO.File]::ReadLines("$_")) { 
                if($line -like "*$id*"){
                    $index = $line.IndexOf("$id", [System.StringComparison]::CurrentCultureIgnoreCase)
                    $length = $id.Length
                    $firstboundary = $line.SubString(0,$index)
                    $secondIndex = $index+$length
                    $lineLength = $line.Length - $secondIndex
                    $lastboundary = $line.SubString($secondIndex, $lineLength)
                    Write-Host -NoNewLine "     ["
                    Write-Host -NoNewLine "+" -ForegroundColor green
                    Write-Host -NoNewLine "] FOUND : $firstboundary"
                    Write-Host -NoNewLine "$id" -BackgroundColor green
                    Write-Host -NoNewline "$lastboundary"
                    Write-Host "`n"
                    if ($RESEARCHMODE -eq 1){
                        $optionEnd = Read-Host -Prompt '     Exit program ? (y/n) '
                        if ($optionEnd -like "*y*") {
                            $loop = $false
                        } elseif ($optionEnd -like "*n*") {
                            $loop = $true
                        }
                        Break condition
                    }
                }
            }
        }

    } elseif ($option -eq 3) {
        $loop = $false
    } else {
        $loop = $false
    }
    $indent = " " * 58
    Write-Host "`n`n$indent~~~~~~~~$indent"
}