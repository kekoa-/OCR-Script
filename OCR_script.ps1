#requires -Version 3.0
#Desired output destination
$exeImageMagick = 'magick.exe' #PDF -> PNG
$exeTesseract = 'tesseract.exe' #OCR Program
$tempFileName = 'temp.txt'
$DESTINATION = "$env:TEMP\ocr\processed_(Get-Date).ToString('yyyyMMddHHmmss')"

#Location of desired PDF to convert
$PDF = (Get-ChildItem -Path $env:USERPROFILE\Downloads\*.pdf | Select-Object -First 1).fullname

#Density of image in DPI
$DENSITY = 600


#custom function to ensure dependant executibles are discoverable
function Test-ExeDiscoverable
{
  <#
      .SYNOPSIS
      ensures executibles are discoverable
      .DESCRIPTION
      this function will also look in the PATH environment variable
      .EXAMPLE
      Test-ExeDiscoverable ping.exe
      .EXAMPLE
      Test-ExeDiscoverable  $someOtherBinary
  #>
  [CmdletBinding()]

  [OutputType([bool])]
  Param
  (
    # Param1 help description
    [Parameter(Mandatory,
        ValueFromPipelineByPropertyName,
    Position = 0)]
    [string]$ExecutibleName
  )
    
  Begin
  {
  }
  Process
  {
    if ((Get-Command $ExecutibleName -ErrorAction SilentlyContinue) -eq $null) 
    {
      Write-Verbose -Message "Unable to find $ExecutibleName in your PATH"
      return $false   
    }
    else 
    {
      Write-Verbose -Message "OK - $ExecutibleName discoverable"
      return $true
    }
  }
  End
  {
  }
}



#ensure imagemagick is discoverable
if (!(Test-ExeDiscoverable -ExecutibleName $exeImageMagick -Verbose))
{
  Write-Verbose -Message "Unable to find $exeImageMagick in your PATH"
  BREAK
}

#$exeTesseract = "${env:ProgramFiles(x86)}\Tesseract-OCR\tesseract.exe" #OCR Program
#ensure tesseract.exe is discoverable
if (!(Test-ExeDiscoverable -ExecutibleName $exeTesseract -Verbose))
{
  #check for Tesseract executible in current user install path
  $exeTesseract = "$env:LOCALAPPDATA\Tesseract-OCR\tesseract.exe"
  if (!(Test-ExeDiscoverable -ExecutibleName $exeTesseract -Verbose))
  {
    BREAK
  }
}


#Location + names of pdf outputs
$DEST1 = $DESTINATION + '\out-%d.pdf'


#use imagemagick to split pdfs into png
& $exeImageMagick -density $DENSITY $PDF +profile '*' ($DESTINATION + 'out.png')

#Create output file for OCR dump
$text_out = New-Item -Path $DESTINATION -Name 'output.txt'

#Creating Temp file for concatenation
$temp = New-Item -Path $DESTINATION -Name $tempFileName

$files2 = Get-ChildItem -Path $DESTINATION
$i = 1
foreach ($f in $files2)
{
  if($f.Extension -eq '.png')
  {
    Write-Verbose -Message "Page  $global:i out of (($files2 | Measure-Object).Count - 2)"
    $global:i++
    # End  of this command is used to mute a warning thrown by tesseract. 
    $null = & $exeTesseract --dpi $DENSITY $f ($temp.DirectoryName + '\' + $temp.BaseName) --psm 6 2>$1 
    Get-Content -Path $temp | Add-Content -Path $text_out
  } 
}
Remove-Item -Path $tempFileName
