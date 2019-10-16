Invoke-Command -ComputerName "Server1" -scriptblock {
#Define update criteria.
$Criteria = "IsInstalled=0 and Type='Software'"

#Search for updates.
$Searcher = New-Object -ComObject "Microsoft.Update.Searcher"
$SearchResult = $Searcher.Search($Criteria).Updates
If ($SearchResult.Count -eq 0) {
        #No need to update
}
else {
        #Need updates 
        #Get Date
                $DateAndTime = (Get-Date -format ddMMMyyyy-HHmm)

                #Register Scheduled Task with Date
                $ScheduledTaskName = "InstallUpdates $DateAndTime"
                Register-ScheduledJob -Name $ScheduledTaskName -RunNow -ScriptBlock {

                #Define update criteria.
                $Criteria = "IsInstalled=0"

                #Search for relevant updates.
                $Searcher = New-Object -ComObject Microsoft.Update.Searcher
                $SearchResult = $Searcher.Search($Criteria).Updates

                #Download updates.
                $Session = New-Object -ComObject Microsoft.Update.Session
                $Downloader = $Session.CreateUpdateDownloader()
                $Downloader.Updates = $SearchResult
                $Downloader.Download()

                #Install updates.
                $Installer = New-Object -ComObject Microsoft.Update.Installer
                $Installer.Updates = $SearchResult

                #Result -> 2 = Succeeded, 3 = Succeeded with Errors, 4 = Failed, 5 = Aborted
                $Result = $Installer.Install()
                } #End scheduledjob scriptblock

                #Output ScheduledJob Name
                $ScheduledTaskName
}

