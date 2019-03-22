##########################################################
# Name:GetGHINIndex
#
# Input: users.txt - each line is a GHIN #
# 
# History: - Tim McCann 2019/03/21
##########################################################

Function Main-GHIN {
############################################################
# Name: Main-GHIN
# Purpose: Main pgm controls the flow
############################################################
param([string]$GHINFile,[string]$OutFilePath)

$PATTERNHandicap='<span id="ctl00_bodyMP_tcItems_tpHandicapCard_headerGolferHandicap"[^>]+>(.*?)</span>'
$PATTERNGolferName='<span id="ctl00_bodyMP_tcItems_tpHandicapCard_headerGolferName"[^>]+>(.*?)</span>'
$PATTERNClubName='<span id="ctl00_bodyMP_tcItems_tpHandicapCard_headerClubName"[^>]+>(.*?)</span>'
$PATTERNHandicapDate='<span id="ctl00_bodyMP_tcItems_tpHandicapCard_headerGolferHandicapDate"[^>]+>(.*?)</span>'
$Outputlines = @()
$Outputlines += "GHIN,INDEX,EFFECTIVE DATE,Name,CLUB"
# exit if GHIN file does not exist
# ? [newlocation] ??
if(!(Test-Path $GHINFile ) -and !(Test-Path [newLocation]))
{
    Write-Host "The file:$GHINFile doesn't exist."
    return
}

$GHINLINES = @(Get-Content $GHINFile | Where-Object { $_ -ne '' } | Where-Object { $_ -NotMatch '#' } )
foreach ($GHINLINE in $GHINLINES)
{
  #($NAME,$GHIN) = $GHINLINE.Split(',')
  $webpage=Call-GHIN-Web -GHIN $GHINLINE
  $Handicap=Get-Pattern-Value -SearchString $webpage -SearchPattern $PATTERNHandicap
  $GolferName=Get-Pattern-Value -SearchString $webpage -SearchPattern $PATTERNGolferName
  $ClubName=Get-Pattern-Value -SearchString $webpage -SearchPattern $PATTERNClubName
  $HandicapDate=Get-Pattern-Value -SearchString $webpage -SearchPattern $PATTERNHandicapDate
  #Write-Host "$GHINLINE,$Handicap,$HandicapDate,$GolferName,$ClubName`r"
  $Outputlines += "$GHINLINE,$Handicap,$HandicapDate,$GolferName,$ClubName"
}
$Outputlines | Out-File -FilePath $OutFilePath


} # END Function Main-GHIN

Function Get-Pattern-Value {
############################################################
# Name: Get-Pattern-Value
# Purpose: To value per pattern 
############################################################
param([string]$SearchString,[string]$SearchPattern)

$strMatch = $SearchString -match $SearchPattern

If ($strMatch) {
    $Match = $SearchString| Select-String -Pattern $SearchPattern
    $returnstr = $Match.Matches -replace '<.*?>'
  } else {
    $returnstr = "blank"
  }
$returnstr 

} # END Function Get-Pattern-Value

Function Call-GHIN-Web {
############################################################
# Name: Call-GHIN-Web
# Purpose: To fetch GHIN index via web call 
############################################################
param([string]$GHIN)
$uri='http://widgets.ghin.com/HandicapLookupResults.aspx?entry=1&ghinno=' + $GHIN +'&css=default&dynamic=&small=0&mode=&tab=0'
[string]$xreturn = Invoke-WebRequest -UseBasicParsing $uri -ContentType "text/xml" -Method Get
$xreturn
} # End function Call-GHIN-Web


# run this program
Main-GHIN -GHINFile "C:\Projects\Golf\users.txt" -OutFilePath "C:\Projects\Golf\GHIN_Output$(get-date -f yyyy_MM_dd_HHMM).txt"
