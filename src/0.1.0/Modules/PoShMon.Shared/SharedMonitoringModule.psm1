﻿Function Format-Gigs
{
    [cmdletbinding()]
    param(
        [parameter(ValueFromPipeline)]$freeSpaceRaw
    )

    $gigsValue = ($freeSpaceRaw/1MB)
   
    return ("{0:F0}" -f $gigsValue) 
    #$([Math]::Round($disk.Size/1GB,2))
}

Function Connect-RemoteSession
{
    [cmdletbinding()]
    param(
        [parameter(Mandatory=$true)][string]$ServerName,
        [string]$ConfigurationName = $null
    )

    if ($ConfigurationName -ne $null)
        { $remoteSession = New-PSSession -ComputerName $ServerName -ConfigurationName $ConfigurationName }
    else
        { $remoteSession = New-PSSession -ComputerName $ServerName }

    return $remoteSession
}

Function Disconnect-RemoteSession
{
    [cmdletbinding()]
    param(
        $RemoteSession
    )

    Remove-PSSession $RemoteSession
}

Function Get-EmailOutput
{
    [cmdletbinding()]
    param(
        $Output
    )

    $emailSection = ''
    $emailSection += '<p><h1>' + $output.SectionHeader + '</h1>'
    $emailSection += '<table border="1">'

    if ($output.OutputValues -ne $null -and $output.OutputValues.Count -gt 0 -and `
        $output.OutputValues[0].ContainsKey("GroupName")) #grouped output
    {
        foreach ($groupOutputValue in $output.OutputValues)
        {    
            $emailSection += '<thead><tr><th align="left" colspan="' + $output.OutputHeaders.Keys.Count + '"><h2>' + $groupOutputValue.GroupName + '</h2></th></tr><tr>'

            $emailSection += (Get-OutputHeadersEmailOutput -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

            $emailSection += (Get-OutputValuesEmailOutput -outputHeaders $output.OutputHeaders -outputValues $groupOutputValue.GroupOutputValues) + '</tbody>'
        }

    } else { #non-grouped output
        $emailSection += '<thead><tr>' + (Get-OutputHeadersEmailOutput -outputHeaders $output.OutputHeaders) + '</tr></thead><tbody>'

        $emailSection += (Get-OutputValuesEmailOutput -outputHeaders $output.OutputHeaders -outputValues $output.OutputValues) + '</tbody>'
    }

    $emailSection += '</table>'

    return $emailSection
}

Function Get-OutputHeadersEmailOutput
{
    [cmdletbinding()]
    param(
        $outputHeaders
    )

    $emailBody = ''

    foreach ($headerKey in $outputHeaders.Keys)
    {
        $header = $outputHeaders[$headerKey]
        $emailBody += '<th align="left">' + $header + '</th>'
    }

    return $emailBody
}

Function Get-OutputValuesEmailOutput
{
    [cmdletbinding()]
    param(
        $outputHeaders,
        $outputValues
    )
    
    $emailSection = ''

    foreach ($outputValue in $outputValues)
    {
        $emailSection += '<tr>'

        foreach ($headerKey in $outputHeaders.Keys)
        {
            $fieldValue = $outputValue[$headerKey]
            if ($outputValue['Highlight'] -ne $null -and $outputValue['Highlight'].Contains($headerKey)) {
                $style = ' style="font-weight: bold; color: red"'
            } else {
                $style = ''
            }

            $align = 'left'
            $temp = ''
            if ([decimal]::TryParse($fieldValue, [ref]$temp))
                { $align = 'right' }

            $emailSection += '<td valign="top"' + $style + ' align="' + $align +'">' + $fieldValue + '</td>'
        }

        $emailSection += '</tr>'
    }

    return $emailSection
}

Function Get-EmailHeader
{
    [CmdletBinding()]
    param(
        [string]$ReportTitle = "PoShMon Monitoring Report"
    )

    $emailSection = '<head><title>' + $ReportTitle + '</title>
</head>
<body>
<h1>' + $ReportTitle + '</h1>'

    return $emailSection;

}

Function Get-EmailFooter
{
    [CmdletBinding()]
    param(
    )

        $emailSection = '</body>'

    return $emailSection;
}
