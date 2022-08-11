$host.UI.RawUI.ForegroundColor = "White"
$loop = $true
$scriptpath = $MyInvocation.MyCommand.Path
$scriptpath = $scriptpath -replace $MyInvocation.MyCommand.Name, ""
Set-Location $scriptpath

#FUNCTIONS

function Update-Config { #REFRESH CONFIG
    Foreach ($i in $(Get-Content config.psd1)){
        Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1] -Scope global
    }

    if($RESEARCHMODE -eq 1){
        $Global:UMODE = @{ Object = 'Yes'; ForegroundColor = 'green' }
    } else { $Global:UMODE = @{ Object = 'No'; ForegroundColor = 'red' }}

    if($RECURSIVEMODE -eq 1){
        $Global:RMODE = @{ Object = 'Yes'; ForegroundColor = 'green' }
    } else { $Global:RMODE = @{ Object = 'No'; ForegroundColor = 'red' }}

    if($CASESENSITIVEMODE -eq 1){
        $Global:CMODE = @{ Object = 'Yes'; ForegroundColor = 'green' }
    } else {
        $Global:CMODE = @{ Object = 'No'; ForegroundColor = 'red' }
    }
    if($VERBOSE -eq 1){
        $Global:VMODE = @{ Object = 'Low'; ForegroundColor = 'darkyellow' }
    } elseif($VERBOSE -eq 2){
        $Global:VMODE = @{ Object = 'High'; ForegroundColor = 'green' }
    } elseif($VERBOSE -eq 0){
        $Global:VMODE = @{ Object = 'No'; ForegroundColor = 'red' }
    }
}

function Update-ConfigValue($VAR, $VARNAME) { #CHANGE A VALUE IN THE CONFIG
    (Get-Content .\config.psd1) | Foreach-Object {
        if ($VAR -eq 0) {
            $_ -replace "$VARNAME=.*", "$VARNAME=1" 
        } else {
            $_ -replace "$VARNAME=.*", "$VARNAME=0" 
        }
    } | Set-Content .\config.psd1
    Update-Config
}

function Update-ConfigValue-Verbose($VAR, $VARNAME) { #CHANGE A VALUE IN THE CONFIG
    (Get-Content .\config.psd1) | Foreach-Object {
        if ($VAR -eq 0) {
            $_ -replace "$VARNAME=.*", "$VARNAME=1" 
        } elseif ($VAR -eq 1) {
            $_ -replace "$VARNAME=.*", "$VARNAME=2" 
        } elseif ($VAR -eq 2) {
            $_ -replace "$VARNAME=.*", "$VARNAME=0" 
        }
    } | Set-Content .\config.psd1
    Update-Config
}

function Recursive-Folder($ORIGINPATH) {
    $Global:totalLines = 0
    Get-ChildItem -Path $ORIGINPATH -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object -Process {
       $completePath = "$ORIGINPATH\$_\"
       if(($_ -ne "") -and ($completepath -ne $scriptpath) -and $RECURSIVEMODE -eq 1) {
				Recursive-Folder $ORIGINPATH\$_
			} 
    }
    Browse-Files "$ORIGINPATH"
}

function Browse-Files($FOLDERPATH) {
    $exit = 0
    Get-ChildItem -Path "$FOLDERPATH\*.txt" | ForEach-Object -Process { #SEARCH FUNC INTO FOLDER 
            if($exit -eq 0) {
                $nbr = 1
                try {
                    if($VERBOSE -eq 2){
                        Write-Host "     [~] $_" -ForegroundColor yellow    
                    }
                    :main foreach($line in [System.IO.File]::ReadLines("$_")) { 
                        if($CASESENSITIVEMODE -eq 1){
                            if($line -clike "*$id*"){
                                if($VERBOSE -ge 1){
                                    $index = $line.IndexOf("$id")
                                    $firstboundary = $line.SubString(0,$index)
                                    $lineLength = $line.Length - ($index+$id.Length)
                                    $lastboundary = $line.SubString($index+$id.Length, $lineLength)
                                    if($VERBOSE -lt 2){
                                        Write-Host "     [~] $_" -ForegroundColor yellow
                                    }
                                    Write-Host -NoNewLine "      | ["
                                    Write-Host -NoNewLine "+" -ForegroundColor green
                                    Write-Host -NoNewLine "] FOUND (Line $nbr) :"
                                    $CharArray = $line -Split ($id)
                                    for($x=0; $x -lt $CharArray.length; $x=$x+1) {
                                        Write-Host -NoNewLine $CharArray[$x]
                                        if($x -lt ($CharArray.length - 1)){Write-Host -NoNewLine "$id" -Backgroundcolor green}
                                    }
                                    Write-Host ""
                                } elseif($VERBOSE -lt 1) {
                                    Add-Content "$scriptpath\$time.txt" ""
                                    Add-Content "$scriptpath\$time.txt" "[~] $_"
                                    Add-Content "$scriptpath\$time.txt" " | [+] (Line $nbr) FOUND : $line"
                                    Add-Content "$scriptpath\$time.txt" ""
                                }
                                $Global:hasFound = $true
                                $Global:occurencesFound++
                                if ($RESEARCHMODE -eq 1){
                                    $exit = 1
                                    Break main
                                }
                            }
                        } elseif($CASESENSITIVEMODE -eq 0){
                            if($line -like "*$id*"){
                                if($VERBOSE -ge 1){
                                    $index = $line.IndexOf("$id", [System.StringComparison]::CurrentCultureIgnoreCase)
                                    $firstboundary = $line.SubString(0,$index)
                                    $lineLength = $line.Length - ($index+$id.Length)
                                    $lastboundary = $line.SubString($index+$id.Length, $lineLength)
                                    if($VERBOSE -lt 2){
                                        Write-Host "     [~] $_" -ForegroundColor yellow
                                    }
                                    Write-Host -NoNewLine "      | ["
                                    Write-Host -NoNewLine "+" -ForegroundColor green
                                    Write-Host -NoNewLine "] FOUND (Line $nbr) : "
                                    $CharArray = $line -Split ($id)
                                    for($x=0; $x -lt $CharArray.length; $x=$x+1) {
                                        Write-Host -NoNewLine $CharArray[$x]
                                        if($x -lt ($CharArray.length - 1)){Write-Host -NoNewLine "$id" -Backgroundcolor green}
                                    }
                                    Write-Host ""
                                } elseif($VERBOSE -lt 1) {
                                    Add-Content "$scriptpath\$time.txt" ""
                                    Add-Content "$scriptpath\$time.txt" "[~] $_"
                                    Add-Content "$scriptpath\$time.txt" " | [+] (Line $nbr) FOUND : $line"
                                    Add-Content "$scriptpath\$time.txt" ""
                                }
                                $Global:hasFound = $true
                                $Global:occurencesFound++
                                if ($RESEARCHMODE -eq 1){
                                    $exit = 1
                                    Break main
                                }
                            }
                        }
                        $nbr = $nbr + 1
                    }
                } catch {}
                $Global:totalLines = $Global:totalLines + $nbr
            }
        }
}

#PROCESSING
While ($loop){
 
    $exit = 0
    Update-Config

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
    Write-Host "   1 - Switch mode                     4 - Switch Verbose (Slow)               0 - Exit"
    Write-Host "   2 - Switch recursive                5 - Open config"
    Write-Host "   3 - Switch case-sensitive           6 - Change research directory`n"
    Write-Host -NoNewLine "   Ready to be launched! (Single = "
    Write-Host -NoNewLine @UMODE
    Write-Host -NoNewLine ", Recursive = "
    Write-Host -NoNewLine @RMODE
    Write-Host -NoNewLine ", Case-sensitive = "
    Write-Host -NoNewLine @CMODE
    Write-Host -NoNewLine ", Verbose = "
    Write-Host -NoNewLine @VMODE
    Write-Host -NoNewLine ", Path = "
    Write-Host -NoNewLine $RESEARCHDIR -ForegroundColor yellow
    Write-Host -NoNewLine ")" 
    Write-Host "`n"
    $option = Read-Host -Prompt '    - Input (Press enter to launch) '

    if ($option -eq "") {
        Update-Config
        $id = Read-Host -Prompt '     Search for '
        Write-Host ""
        Write-Host -NoNewLine "     OK! " -ForegroundColor green
        Write-Host -NoNewLine "Starting researches... (Research mode set to $RESEARCHMODE)"
        Write-Host ""

        $time = Get-Date -Format "dd,MM,yyyy HH-mm-ss"
        New-Item "$scriptpath\$time.txt" | Out-Null
        Add-Content "$scriptpath\$time.txt" "RABBIT V2.2 OUTPUT | Expression : $id"
        $sepHead = "=" * (34 + $id.Length)
        Add-Content "$scriptpath\$time.txt" "$sepHead"

        $Global:hasFound = $false
        $Global:occurencesFound = 0

        $StartTime=(GET-DATE -Format "dd/MM/yyyy HH:mm:ss")

        Recursive-Folder $RESEARCHDIR

        $EndTime=(GET-DATE -Format "dd/MM/yyyy HH:mm:ss")
        $TimeInterval = NEW-TIMESPAN –Start $StartTime –End $EndTime
        $TotalSeconds = $TimeInterval.TotalSeconds
        $SearchRate = $Global:TotalLines / $TotalSeconds

        if(-Not $Global:hasFound) {
            Write-Host -NoNewLine "     NOTHING! " -ForegroundColor red
            Write-Host -NoNewLine "has been found ($TimeInterval, $totalLines lines, $SearchRate lines/s)."
        } else { 
            Write-Host -NoNewLine "     DONE! " -ForegroundColor green
            Write-Host -NoNewLine "$Global:occurencesFound occurences have been found ($TimeInterval, $totalLines lines, $SearchRate lines/s)."
            if($VERBOSE -lt 1) {    
                Invoke-Item "./$time.txt"
            }
        }


        Write-Host "`n"
        $optionEnd = Read-Host -Prompt '     Exit program ? (y/n) '
            if ($optionEnd -like "*y*") {
                $loop = $false
            } elseif ($optionEnd -like "*n*") {
                $loop = $true
            }
    } if ($option -like "*1*") {
        Update-ConfigValue $RESEARCHMODE "RESEARCHMODE"
    } if ($option -like "*2*") {
        Update-ConfigValue $RECURSIVEMODE "RECURSIVEMODE"
    } if ($option -like "*3*") {
        Update-ConfigValue $CASESENSITIVEMODE "CASESENSITIVEMODE"
    } if ($option -like "*4*") {
        Update-ConfigValue-Verbose $VERBOSE "VERBOSE"
    } if ($option -like "*5*"){
        Invoke-Item "./config.psd1"
    } if ($option -like "*6*") {
        Function GetResearchFolder($initialDirectory) {
            [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
            $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
            $FolderBrowserDialog.RootFolder = 'MyComputer'
            if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
            [void] $FolderBrowserDialog.ShowDialog()
            return $FolderBrowserDialog.SelectedPath
        }
        $NewResearchDir = GetResearchFolder($RESEARCHDIR)
        (Get-Content .\config.psd1) | Foreach-Object { $_ -replace 'RESEARCHDIR=.*', "RESEARCHDIR=$NewResearchDir" } | Set-Content .\config.psd1
        Foreach ($i in $(Get-Content config.psd1)){
            Set-Variable -Name $i.split("=")[0] -Value $i.split("=",2)[1]
        }
    } if (($option -like "q" ) -or ($option -like "0" ) -or ($option -like "e" )){
        $loop = $false
    } 
    cls
}