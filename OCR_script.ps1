#Desired output destination
$tempFileName = 'temp.txt'
$DESTINATION = "$env:TEMP\ocr\processed_(Get-Date).ToString('yyyyMMddHHmmss')"

#Location of desired PDF to convert
$PDF = (Get-childitem -path $env:USERPROFILE\Downloads\*.pdf | Select-Object -First 1).fullname

#Density of image in DPI
$DENSITY = 600

$MAG = 'magick.exe'  #PDF -> PNG
$TES = "${env:ProgramFiles(x86)}\Tesseract-OCR\tesseract.exe" #OCR Program

if (!(Test-Path -Path $TES)){
#check for tesseract executible in current user install path
  $TES = "$env:LOCALAPPDATA\Tesseract-OCR\tesseract.exe"
}


#Location + names of pdf outputs
$DEST1 = $DESTINATION + '\out-%d.pdf'


#use imagemagick to split pdfs into png
& $MAG -density $DENSITY $PDF +profile '*' ($DESTINATION + 'out.png')

#Create output file for OCR dump
$text_out = New-Item -Path $DESTINATION -Name 'output.txt'

#Creating Temp file for concatenation
$temp = New-Item -Path $DESTINATION -Name $tempFileName

$files2 = Get-ChildItem -Path $DESTINATION
$i = 1
foreach ($f in $files2){
    
    if($f.Extension -eq '.png'){
        Write-Verbose -Message "Page  $global:i out of (($files2 | Measure-Object).Count - 2)"
        $global:i++
        # End  of this command is used to mute a warning thrown by tesseract. 
        & $TES --dpi $DENSITY $f ($temp.DirectoryName + '\' + $temp.BaseName) --psm 6 2>$1 | Out-Null 
        Get-Content -Path $temp | Add-Content -Path $text_out
    } 
}
Remove-Item -Path $tempFileName
