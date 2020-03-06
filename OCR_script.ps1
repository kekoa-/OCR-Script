#Desired output destination
$DESTINATION = {Path to destination}

#Location of desired PDF to convert
$PDF = {Path to PDF}

#Density of image in DPI
$DENSITY = 600

$PDFTK = 'pdftk.exe' #PDF splitter
$MAG = 'magick.exe'  #PDF -> PNG
$TES = 'C:\Program Files (x86)\Tesseract-OCR\tesseract.exe' #OCR Program


#Location + names of pdf outputs
$DEST1 = $DESTINATION + '\out-%d.pdf'

#Splits pdf into single pages
#& $PDFTK $PDF burst output $DEST1
#remove some pdf data output
#rm doc_data.txt
#$files1 = Get-ChildItem $DESTINATION
#Converting each pdf to a png, not in order because 10 comes before 2
#foreach ($f in $files1){
#    if($f.Extension -eq '.pdf'){
#        & $MAG -density 200 $f +profile "*" ($DESTINATION + $f.BaseName + '.png')
#    }
#}
#rm *.pdf

#The above was unnecessary because imagemagick splits pages by default
& $MAG -density $DENSITY $PDF +profile "*" ($DESTINATION + 'out.png')

#Create output file for OCR dump
$text_out = New-Item -Path $DESTINATION -Name 'output.txt'

#Creating Temp file for concatenation
$temp = New-Item -Path $DESTINATION -Name 'temp.txt'

$files2 = Get-ChildItem $DESTINATION
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
