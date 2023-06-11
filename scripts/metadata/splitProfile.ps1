# @author: Liquad Li
# @description: To split "*.profile-meta.xml" into multiple small files.
# Enter the parent folder of "force-app".
# MacOS user need install Powershell Core.
#
#>
param(
    [string] $SourcePath = "force-app"
)

$profilePath = ".\${SourcePath}\main\default\profiles"
Write-Host "Split profile under: ${profilePath}"
$env:BUILD_SOURCESDIRECTORY = $profilePath
$env:BUILD_STAGINGDIRECTORY = $profilePath

function Split-ProfileFile {
    param (
        $profileName,
        $removeSrcFile = $false
    )

    process {
        $postfix = ".profile-meta.xml"
        $filename = $profileName + $postfix
        $filepath = Join-Path -Path $env:BUILD_SOURCESDIRECTORY -ChildPath $filename
        $stagingpath = Join-Path -Path $env:BUILD_STAGINGDIRECTORY -ChildPath $profileName

        $section2keyname = @{
            applicationVisibilities    = @{key = "application" };
            categoryGroupVisibilities  = @{key = "dataCategoryGroup" };
            classAccesses              = @{key = "apexClass" };
            customPermissions          = @{key = "name" };
            customMetadataTypeAccesses = @{key = "name" };
            customSettingAccesses      = @{key = "name" };
            externalDataSourceAccesses = @{key = "externalDataSource" };
            fieldPermissions           = @{key = "field"; splitbyobject = "true" };
            flowAccesses               = @{key = "flow" };
            layoutAssignments          = @{key = "layout"; key2 = "recordType" };

            loginIpRanges              = @{key = "startAddress"; key2 = "endAddress" };
            objectPermissions          = @{key = "object" };
            pageAccesses               = @{key = "apexPage" };
            profileActionOverrides     = @{key = "actionName" };

            recordTypeVisibilities     = @{key = "recordType" };
            tabVisibilities            = @{key = "tab" };
            userPermissions            = @{key = "name" };

            custom                     = @{key = "name" }
            userLicense                = @{key = "name" }
        }

        $currentXml = $null
        $currentKeyName2Node = @{}

        try {

            Write-Host "Spliting $profileName"

            if (-not(Test-Path -Path $filepath)) {
                Write-Host "File not exist: $filepath"
                return
            }

            if (-Not (Test-Path -Path $stagingpath)) {
                md $stagingpath | Out-Null
            }

            $settings = New-Object System.Xml.XmlWriterSettings
            $settings.IndentChars = "    "
            $settings.Indent = $true
            #NewLineChars will affect all newlines
            #$settings.NewLineChars ="`r`n"
            #Set an optional encoding, UTF-8 is the most used (without BOM)
            $settings.Encoding = New-Object System.Text.UTF8Encoding( $false )

            #get xml data via filename
            [xml]$xmldata = (Get-Content $filepath -Encoding UTF8)
            if (-not($xmldata)) {
                throw "Xml parsing error."
            }
            $nodes = $xmldata.Profile.ChildNodes

            $header = '<?xml version="1.0" encoding="UTF-8"?><Profile xmlns="http://soap.sforce.com/2006/04/metadata">'
            $footer = "</Profile>"

            $nodeCount = $nodes.Count
            Write-Host "Nodes count: $nodeCount"
            $sectionNotSupport = ""
            $lastStagingFullPath = ""
            foreach ($subj in $nodes) {
                $sectionName = $subj.LocalName

                $keyName = ""
                $keyType = ""
                $key2 = ""
                $splitbyobject = ""
                if ($section2keyname.ContainsKey($sectionName)) {
                    $keyType = $section2keyname[$sectionName].key
                    $key2 = $section2keyname[$sectionName].key2
                    $splitbyobject = $section2keyname[$sectionName].splitbyobject
                    $keyName = $subj.$keyType
                    if ($key2 -ne "") {
                        $keyName += "." + $subj.$key2
                    }
                }
                else {
                    #throw "$sectionName is not supported"
                    $sectionNotSupport += "`r`n" + $sectionName
                    continue
                }

                if ($splitbyobject -eq "true") {
                    $objectName = $keyName.Split(".")[0]
                    $stagingFullPath = Join-Path -Path $stagingpath -ChildPath ($subj.LocalName + "." + $objectName + $postfix)
                }
                else {
                    $stagingFullPath = Join-Path -Path $stagingpath -ChildPath ($subj.LocalName + $postfix)
                }

                if (($stagingFullPath -ne $lastStagingFullPath)) {
                    if ($currentXml -and ($lastStagingFullPath -ne "")) {
                        if (Test-Path $lastStagingFullPath) {
                            Remove-Item -Force -Path $lastStagingFullPath
                        }
                        $xmlWriter = [System.Xml.XmlWriter]::Create($lastStagingFullPath, $settings)
                        $currentXml.Save($xmlWriter)
                        $xmlWriter.Close()
                    }

                    $currentXml = $null
                    $currentKeyName2Node = @{}
                    $lastStagingFullPath = $stagingFullPath
                }

                $allNodes = $null
                $keyName2Node = $null
                if (-not($currentXml)) {
                    if ((Test-Path -Path $stagingFullPath)) {
                        $allNodes = [xml](Get-Content $stagingFullPath -Encoding UTF8)
                        $currentXml = $allNodes;

                        $keyName2Node = @{}
                        foreach ($oneNode in $allNodes.ChildNodes[1].ChildNodes) {
                            $keyNameExisting = $oneNode.$keyType
                            if ($key2 -ne "") {
                                $keyNameExisting += "." + $oneNode.$key2
                            }
                            $keyName2Node.Add($keyNameExisting, $oneNode)
                        }

                        $currentKeyName2Node = $keyName2Node
                    }
                    else {
                        [xml]$splitfile = $header + $subj.OuterXml + $footer
                        $splitfile.ChildNodes[1].FirstChild.Attributes.RemoveNamedItem("xmlns") | Out-Null
                        $currentXml = $splitfile
                        $keyName2Node = @{ $keyName = $splitfile.ChildNodes[1].FirstChild }
                        $currentKeyName2Node = $keyName2Node
                        continue
                    }
                }
                else {
                    $allNodes = $currentXml
                    $keyName2Node = $currentKeyName2Node
                }

                if ($keyName2Node.ContainsKey($keyName)) {
                    $oneNode = $keyName2Node[$keyName]
                    if ($oneNode.InnerText -ne $subj.InnerText) {
                        #update
                        $newNode = $allNodes.ImportNode($subj, $true)
                        $allNodes.ChildNodes[1].ReplaceChild($newNode, $oneNode) | Out-Null
                        #Write-Host "Replaced"
                    }
                }
                else {
                    #add
                    $newNode = $allNodes.ImportNode($subj, $true)
                    $allNodes.ChildNodes[1].AppendChild($newNode) | Out-Null
                    $keyName2Node[$keyName] = $newNode
                    #Write-Host "Added"
                }

            }

            if ($currentXml -and ($lastStagingFullPath -ne "")) {
                $currentXml.Save([System.Xml.XmlWriter]::Create($lastStagingFullPath, $settings))
            }

            #Write-Host "Nodes count: $nodeCount"

            if ($sectionNotSupport -ne "") {
                Write-Host "Section not support:"
                Write-Host $sectionNotSupport
            }

        } # end try
        catch {
            throw
        }

        if ($removeSrcFile) {
            Remove-Item -Path $filepath -Force
        }
    }
}
#

if ([string]::IsNullOrEmpty($SourcePath)) {
    Write-Host "Parameter SourcePath may not be empty"
}
else {
    $allFiles = Get-ChildItem -Path (Join-Path -Path $env:BUILD_SOURCESDIRECTORY -ChildPath "*.profile-meta.xml")
    $allFilesCount = $allFiles.Count
    Write-Host "All files count: $allFilesCount"

    foreach ($oneFile in $allFiles) {
        $profileName = $oneFile.Name.Split(".")[0]
        #Write-Host $profileName
        Split-ProfileFile -profileName $profileName -removeSrcFile $true
    }
    #>
    #Split-ProfileFile -profileName "B2BMA Integration User" -removeSrcFile $false
}
