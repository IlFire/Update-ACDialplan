param(
    # percorso file del dialplan da modificare
    [Parameter()]
    [string]$dialplan = ".\resource\dialplan_s4b.csv",

    # percorso file dei numeri da modificare/inserire
    [Parameter()]
    [string]$tomigrate = ".\resource\phonetoteams.csv",

    # definisce se i nueri vanno migrati verso TEAMS o S4B
    [Parameter()]
    [validateset ("S4B", "TEAMS")]
    [string]
    $dest = "TEAMS"
)


$lineuris = @()
$NewDialPlan = @(Import-Csv -path $dialplan )
import-csv -path $tomigrate | ForEach-Object {

    $BaseName = $_.lineuri

    if ($NewDialPlan -is [system.array]) { $Found = $NewDialPlan | Where-Object { $NewDialPlan.prefix -eq $BaseName } }

        
    if ($Found) {
        $phonetoteams = @{}
        import-csv -path $tomigrate | ForEach-Object { $phonetoteams[$_.lineuri] = $_.lineuri }


        $NewDialPlan |  ForEach-Object {
            if ($phonetoteams.ContainsKey($_.prefix)) {
                $_.tag = $dest
            }
            #$_
        }
    }
    else {
        $lineuri = New-Object PSObject
        $lineuri | Add-Member -Type NoteProperty -Name DialPlanName -Value "cattolica"
        $lineuri | Add-Member -Type NoteProperty -Name Name -Value $Basename
        $lineuri | Add-Member -Type NoteProperty -Name Prefix -Value $Basename
        $lineuri | Add-Member -Type NoteProperty -Name Tag -Value $dest
        $lineuris += $lineuri
        $lineuri = $null 
    }
}

$lineuri = $NewDialPlan + $lineuris
$lineuri | export-csv -Path ".\resource\newdialplan.csv" -Delimiter "," -NoTypeInformation
