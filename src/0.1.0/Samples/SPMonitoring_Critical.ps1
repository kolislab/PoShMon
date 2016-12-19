﻿Import-Module "C:\Dev\GitHub\PoShMon\src\0.1.0\Modules\PoShMon.psd1" #This is only necessary if you haven't installed the module into your Modules folder, e.g. via PowerShellGallery / Install-Module

$WebtestDetails = @{ "http://intranet" = "something on the page"; "http://extranet.company.com" = "Something on the page" }
Invoke-SPMonitoringCritical -MinutesToScanHistory 15 -PrimaryServerName 'SPAPPSVR01' -MailToList "SharePointTeam@Company.com" -EventLogCodes "Critical" -WebsiteDetails $WebtestDetails -SendEmail $true -SendEmailOnlyOnFailure $true -ConfigurationName SpFarmPosh -MailFrom "Monitoring@company.com" -SMTPAddress "EXCHANGE.COMPANY.COM" -Verbose

#Remove-Module PoShMon