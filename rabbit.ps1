$host.UI.RawUI.ForegroundColor = "White"
$loop = $true
$scriptpath = $MyInvocation.MyCommand.Path
$scriptpath = $scriptpath -replace $MyInvocation.MyCommand.Name, ""
Set-Location $scriptpath

Foreach ($i in $(Get-Content config.psd1)){
        Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
}

While ($loop){

    Write-Host "========================================================================================================================`n"
    Write-Host '       "               /|      __                    "                       +                   .   '
    Write-Host ' *        "    +      / |   ,-~ /             +    "                 .                  .           '
    Write-Host '   "   .             Y :|  //  /                .         *"                 .                             .'
    Write-Host '         .   "       | jj /( .^     *"                               +               +              '
    Write-Host '                *   ^>-"~"-v"              .        *        .                                      . '
    Write-Host '*    "              /       Y"                                            +                         '
    Write-Host '    .     .   "    jo  o    |     .            +"                   .                  .            '
    Write-Host -NoNewLine '     "            ( ~'
    Write-Host -NoNewLine 'T' -ForegroundColor magenta
    Write-Host -NoNewLine '~     j                     +     ."                    .                 +    '
    Write-Host ""
    Write-Host '        +    "     >._-~ _./         +"                                                                      .'
    Write-Host '  "             /| :-~~ _  l"                               .                   .                   .'
    Write-Host '   .           / l/ ,-"~    \     +                                       +              +          '
    Write-Host '               \//\/      .- \               +                                                      '
    Write-Host '        +       Y        /    Y"                   ___    _   ___ ___ ___ _____                           "+'
    Write-Host '                l       I     !"                  | _ \  /_\ | _ ) _ )_ _|_   _|   "     +          '
    Write-Host '           "    ]\      _\    /~\                 |   / / _ \| _ \ _ \| |  | |                   "  +'
    Write-Host '     "         (~ ~----( ~   Y.  )         +      |_|_\/_/ \_\___/___/___| |_|        "             .'
    Write-Host '           ~~~~~~~~~~~~~~~~~~~~~~~~~~                                                               ' -ForegroundColor green
    Write-Host '                                          Research Assistant for Big Big Information Tables'
    Write-Host "`n========================================================================================================================`n"

    $exit = 0
    Write-Host "   1 - Launch"
    if($RESEARCHMODE -eq 1){
        $MODE = "One occurence"
    } else {$MODE = "Multiple occurences"}
    Write-Host "   2 - Open config (Mode = $MODE, Path = $RESEARCHDIR)"
    Write-Host "   3 - Actualize config"
    Write-Host "   4 - Exit`n"
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
            if($exit -eq 0) {
                Write-Host -NoNewLine "     ["
                Write-Host -NoNewLine "~" -ForegroundColor yellow
                Write-Host -NoNewLine "] $_"
                Write-Host ""
                :main foreach($line in [System.IO.File]::ReadLines("$_")) { 
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
                            $exit = 1 
                            $optionEnd = Read-Host -Prompt '     Exit program ? (y/n) '
                            if ($optionEnd -like "*y*") {
                                $loop = $false
                                Break main
                            } elseif ($optionEnd -like "*n*") {
                                $loop = $true
                                Break main
                            } else {
                                $loop = $false
                                Break main
                            }
                        }
                    }
                }
            }
        }

    } elseif ($option -eq 3) {
        Foreach ($i in $(Get-Content config.psd1)){
            Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
        }
    } elseif ($option -eq 4) {
        $loop = $false
    } else {
        $loop = $false
    }
    cls
}