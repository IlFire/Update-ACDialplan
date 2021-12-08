<#
.SYNOPSIS
    This script update tags for Audiocdes SBC dialplan
.DESCRIPTION
    from a start dialplan, the script serach if a prfix exist and change the TAG of the prefix,
    if a prefix does not exist create a new record in the dial plan
.EXAMPLE
    PS C:\> update-dialplan.ps1 -DialPlan ".\resource\dialplan.csv" -ToMigrate ".\resource\tomigrate.csv" -tag "PSTN"
    
    the script update the tag value to value "PSTN" of the original dialplan for the lineuri listed in the file tomigrate.csv and 
    add new line in the dialplan if lineuri dosen't exist
.INPUTS
    -dialplan (path of the original dialplan csv file)
    -ToMigarte (path of the csv file with list of lineuri to modify/add)
    -tag (the new value of the Tag field)
.OUTPUTS
    a new csv file with the modifyed dialplan to import into SBC will be created into .\resource\newdialplan.csv
.NOTES
    
#>


param(
    # Parameter help description
    [Parameter(Mandatory)]
    [string]$DPName,

    # percorso file del dialplan da modificare
    [Parameter()]
    [string]$DialPlan = ".\resource\dialplan.csv",

    # percorso file dei numeri da modificare/inserire
    [Parameter()]
    [string]$ToMigrate = ".\resource\tomigrate.csv",

    # definisce se i nueri vanno migrati verso TEAMS o S4B
    [Parameter()]
    [string]$Tag = "PSTN"
)

$lineuris = @()
$NewDialPlan = @(Import-Csv -path $dialplan )
import-csv -path $tomigrate | ForEach-Object {

    $BaseName = $_.lineuri

    if ($NewDialPlan -is [system.array]) { $Found = $NewDialPlan | Where-Object { $NewDialPlan.prefix -eq $BaseName } }

    if (!($Found)) {     

        $lineuri = New-Object PSObject
        $lineuri | Add-Member -Type NoteProperty -Name DialPlanName -Value $DPName
        $lineuri | Add-Member -Type NoteProperty -Name Name -Value $Basename
        $lineuri | Add-Member -Type NoteProperty -Name Prefix -Value $Basename
        $lineuri | Add-Member -Type NoteProperty -Name Tag -Value $Tag
        $lineuris += $lineuri
        $lineuri = $null 
    }
    
}


$phonetoteams = @{}
import-csv -path $tomigrate | ForEach-Object { $phonetoteams[$_.lineuri] = $_.lineuri }


$NewDialPlan |  ForEach-Object {
    if ($phonetoteams.ContainsKey($_.prefix)) {
        $_.tag = $Tag
    }
    #$_
}
   

$lineuri = $NewDialPlan + $lineuris
$lineuri | export-csv -Path ".\resource\newdialplan.csv" -Delimiter "," -NoTypeInformation