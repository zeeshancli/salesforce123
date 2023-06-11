# @author: Liquad Li
# @date: 2020-04-30
# @description: Merge profile small files into single.
param(
    [string] $SourcePath = "force-app"
)

function merge-Profile {
    param (
        $profileSubPath = "${SourcePath}/main/default/profiles/<profileName>",
        $removeSrc = $false
    )
    process {
        $rootNode = "Profile"
        $postfix = ".profile-meta.xml"
        $profileName = Split-Path -Path $profileSubPath -Leaf
        $typePath = Split-Path -Path $profileSubPath
        $filename = $profileName + $postfix

        $wholeFilePath = Join-Path -Path $typePath -ChildPath $filename

        if (-not(Test-Path -Path $profileSubPath)) {
            return
        }

        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.IndentChars = "    "
        $settings.Indent = $true
        #NewLineChars will affect all newlines
        #$settings.NewLineChars ="`r`n"
        #Set an optional encoding, UTF-8 is the most used (without BOM)
        $settings.Encoding = New-Object System.Text.UTF8Encoding($false)

        $allFiles = Get-ChildItem -Path "$profileSubPath/*$postfix"
        $fileCount = $allFiles.Count
        Write-Host "Found files: $fileCount"
        if ($allFiles.Count -eq 0) {
            Write-Host "No files to be merged"
            Remove-Item -Path $profileSubPath -Force
            return
        }
        elseif ($allFiles.Count -eq 1) {
            Move-Item -Path $allFiles[0].PSPath -Destination $wholeFilePath -Force
            Remove-Item -Path $profileSubPath -Force
            return
        }

        $allNodes = [xml](Get-Content $allFiles[0].PSPath -Encoding UTF8)
        #Remove-Item -Path $allFiles[0].PSPath

        for ($index = 1; $index -lt $allFiles.Count; $index++) {
            $filepath = $allFiles[$index].PSPath

            if ($filepath -eq $wholeFilePath) {
                continue
            }

            #get xml data via filename
            [xml]$xmldata = (Get-Content $filepath -Encoding UTF8)
            $nodes = $xmldata.$rootNode.ChildNodes

            foreach ($subj in $nodes) {
                $newNode = $allNodes.ImportNode($subj, $true)
                $allNodes.ChildNodes[1].AppendChild($newNode) | Out-Null
            }
        }

        if (-Not (Test-Path -Path $typePath)) {
            mkdir $typePath
        }

        $allNodes.Save([System.Xml.XmlWriter]::Create($wholeFilePath, $settings))

        if ($removeSrc) {
            Remove-Item -Path $profileSubPath -Force -Recurse
        }
    }
}

function merge-ProfileInFolder {
    param ($Path)
    process {
        if (-not(Test-Path -Path $Path -PathType Container)) {
            return
        }
        $allFiles = Get-ChildItem -Path $Path -Directory
        $allFilesCount = $allFiles.Count
        Write-Host "All profiles count: $allFilesCount"

        foreach ($oneFile in $allFiles) {
            merge-Profile -profileSubPath $oneFile.FullName -removeSrc $true
        }
    }
}

if ([string]::IsNullOrEmpty($SourcePath)) {
    Write-Host "Parameter SourcePath may not be empty"
}
else {
    $profilePath = "./${SourcePath}/main/default/profiles"
    Write-Host "Merge profiles under: ${profilePath}"
    merge-ProfileInFolder -Path $profilePath
}
