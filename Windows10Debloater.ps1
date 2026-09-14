#This function finds any AppX/AppXProvisioned package and uninstalls it, except for Freshpaint, Windows Calculator, Windows Store, and Windows Photos.
#Also, to note - This does NOT remove essential system services/software/etc such as .NET framework installations, Cortana, Edge, etc.

#This will self elevate the script so with a UAC prompt since this script needs to be run as an Administrator in order to function properly.
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator')) {
    Write-Host "You didn't run this script as an Administrator. This script will self elevate to run as an Administrator and continue."
    Start-Sleep 1
    Write-Host "                                               3"
    Start-Sleep 1
    Write-Host "                                               2"
    Start-Sleep 1
    Write-Host "                                               1"
    Start-Sleep 1
    Start-Process powershell.exe -ArgumentList ("-NoProfile -ExecutionPolicy Bypass -File `"{0}`"" -f $PSCommandPath) -Verb RunAs
    Exit
}

#no errors throughout
$ErrorActionPreference = 'Continue'

# Import stability functions
$StabilityScript = Join-Path $PSScriptRoot "StabilityFunctions.ps1"
If (Test-Path $StabilityScript) {
    . $StabilityScript
} Else {
    throw "StabilityFunctions.ps1 is required. Extract the complete repository before running this script."
}

$DebloatFolder = "C:\Temp\Windows10Debloater"
If (Test-Path $DebloatFolder) {
    Write-Output "$DebloatFolder exists. Skipping."
}
Else {
    Write-Output "The folder '$DebloatFolder' doesn't exist. This folder will be used for storing logs created after the script runs. Creating now."
    Start-Sleep 1
    New-Item -Path "$DebloatFolder" -ItemType Directory
    Write-Output "The folder $DebloatFolder was successfully created."
}

Start-Transcript -OutputDirectory "$DebloatFolder"

Add-Type -AssemblyName PresentationCore, PresentationFramework

Function DebloatAll {
    #Removes AppxPackages
    #Credit to /u/GavinEke for a modified version of my whitelist code
    $WhitelistedApps = 'Microsoft.ScreenSketch|Microsoft.WindowsCalculator|Microsoft.WindowsStore|Microsoft.Windows.Photos|CanonicalGroupLimited.UbuntuonWindows|Microsoft.XboxGameCallableUI|Microsoft.XboxGamingOverlay|Microsoft.Xbox.TCUI|Microsoft.XboxIdentityProvider|Microsoft.MicrosoftStickyNotes|Microsoft.MSPaint|Microsoft.WindowsCamera|.NET|Framework|Microsoft.HEIFImageExtension|Microsoft.StorePurchaseApp|Microsoft.VP9VideoExtensions|Microsoft.WebMediaExtensions|Microsoft.WebpImageExtension|Microsoft.DesktopAppInstaller|WindSynthBerry|MIDIBerry|Slack'
    #NonRemovable Apps that were getting attempted and the system would reject the uninstall, speeds up debloat and prevents 'initializing' overlay when removing apps
    $NonRemovable = '1527c705-839a-4832-9118-54d4Bd6a0c89|c5e2524a-ea46-4f67-841f-6a9465d9d515|E2A4F912-2574-4A75-9BB0-0D023378592B|F46D4000-FD22-4DB4-AC8E-4E1DDDE828FE|InputApp|Microsoft.AAD.BrokerPlugin|Microsoft.AccountsControl|Microsoft.BioEnrollment|Microsoft.CredDialogHost|Microsoft.ECApp|Microsoft.LockApp|Microsoft.MicrosoftEdgeDevToolsClient|Microsoft.MicrosoftEdge|Microsoft.PPIProjection|Microsoft.Win32WebViewHost|Microsoft.Windows.Apprep.ChxApp|Microsoft.Windows.AssignedAccessLockApp|Microsoft.Windows.CapturePicker|Microsoft.Windows.CloudExperienceHost|Microsoft.Windows.ContentDeliveryManager|Microsoft.Windows.Cortana|Microsoft.Windows.NarratorQuickStart|Microsoft.Windows.ParentalControls|Microsoft.Windows.PeopleExperienceHost|Microsoft.Windows.PinningConfirmationDialog|Microsoft.Windows.SecHealthUI|Microsoft.Windows.SecureAssessmentBrowser|Microsoft.Windows.ShellExperienceHost|Microsoft.Windows.XGpuEjectDialog|Microsoft.XboxGameCallableUI|Windows.CBSPreview|windows.immersivecontrolpanel|Windows.PrintDialog|Microsoft.VCLibs.140.00|Microsoft.Services.Store.Engagement|Microsoft.UI.Xaml.2.0|Nvidia|Acer|Asus|Dell|HP|Lenovo|Toshiba'
    Get-AppxPackage -AllUsers | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable} | Remove-AppxPackage
    Get-AppxPackage | Where-Object {$_.Name -NotMatch $WhitelistedApps -and $_.Name -NotMatch $NonRemovable} | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -NotMatch $WhitelistedApps -and $_.PackageName -NotMatch $NonRemovable} | Remove-AppxProvisionedPackage -Online
}

Function DebloatBlacklist {

    $Bloatware = @(

        #Unnecessary Windows 10 AppX Apps
        "Microsoft.BingNews"
        "Microsoft.GetHelp"
        "Microsoft.Getstarted"
        "Microsoft.Messaging"
        "Microsoft.Microsoft3DViewer"
        "Microsoft.MicrosoftOfficeHub"
        "Microsoft.MicrosoftSolitaireCollection"
        "Microsoft.NetworkSpeedTest"
        "Microsoft.News"
        "Microsoft.Office.Lens"
        "Microsoft.Office.OneNote"
        "Microsoft.Office.Sway"
        "Microsoft.OneConnect"
        "Microsoft.People"
        "Microsoft.Print3D"
        "Microsoft.Paint3D"
        "Microsoft.RemoteDesktop"
        "Microsoft.SkypeApp"
        "Microsoft.StorePurchaseApp"
        "Microsoft.Office.Todo.List"
        "Microsoft.Whiteboard"
        "Microsoft.WindowsAlarms"
        #"Microsoft.WindowsCamera"
        "microsoft.windowscommunicationsapps"
        "Microsoft.WindowsFeedbackHub"
        "Microsoft.WindowsMaps"
        "Microsoft.WindowsSoundRecorder"
        "Microsoft.Xbox.TCUI"
        "Microsoft.XboxApp"
        "Microsoft.XboxGameOverlay"
        "Microsoft.XboxIdentityProvider"
        "Microsoft.XboxSpeechToTextOverlay"
        "Microsoft.ZuneMusic"
        "Microsoft.ZuneVideo"
        "Microsoft.MixedReality.Portal"

        #Sponsored Windows 10 AppX Apps
        #Add sponsored/featured apps to remove in the "*AppName*" format
        "*EclipseManager*"
        "*ActiproSoftwareLLC*"
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Duolingo-LearnLanguagesforFree*"
        "*PandoraMediaInc*"
        "*CandyCrush*"
        "*BubbleWitch3Saga*"
        "*Wunderlist*"
        "*Flipboard*"
        "*Twitter*"
        "*Facebook*"
        "*Spotify*"
        "*Minecraft*"
        "*Royal Revolt*"
        "*Sway*"
        "*Speed Test*"
        "*Dolby*"

        #Modern bloatware (added in newer Windows 10 builds)
        "*Clipchamp.Clipchamp*"
        "*Microsoft.Todos*"
        "*Microsoft.PowerAutomateDesktop*"
        "*MicrosoftTeams*"
        "*Microsoft.549981C3F5F10*"
        "*Disney*"
        "*SpotifyAB.SpotifyMusic*"
        "*Microsoft.GamingApp*"
        "*Microsoft.YourPhone*"
             
        #Optional: Typically not removed but you can if you need to for some reason
        #"*Microsoft.Advertising.Xaml_10.1712.5.0_x64__8wekyb3d8bbwe*"
        #"*Microsoft.Advertising.Xaml_10.1712.5.0_x86__8wekyb3d8bbwe*"
        #"*Microsoft.BingWeather*"
        #"*Microsoft.MSPaint*"
        #"*Microsoft.MicrosoftStickyNotes*"
        #"*Microsoft.Windows.Photos*"
        #"*Microsoft.WindowsCalculator*"
        #"*Microsoft.WindowsStore*"
    )
    foreach ($Bloat in $Bloatware) {
        Get-AppxPackage -Name $Bloat| Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -like $Bloat | Remove-AppxProvisionedPackage -Online
        Write-Output "Trying to remove $Bloat."
    }
}

Function Remove-Keys {
        
    #These are the registry keys that it will delete.
            
    $Keys = @(
            
        #Remove Background Tasks
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.BackgroundTasks\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
        #Windows File
        "HKCR:\Extensions\ContractId\Windows.File\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
            
        #Registry keys to delete if they aren't uninstalled by RemoveAppXPackage/RemoveAppXProvisionedPackage
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\46928bounde.EclipseManager_2.2.4.51_neutral__a5h4egax66k6y"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Launch\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
            
        #Scheduled Tasks to delete
        "HKCR:\Extensions\ContractId\Windows.PreInstalledConfigTask\PackageId\Microsoft.MicrosoftOfficeHub_17.7909.7600.0_x64__8wekyb3d8bbwe"
            
        #Windows Protocol Keys
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.PPIProjection_10.0.15063.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.15063.0.0_neutral_neutral_cw5n1h2txyewy"
        "HKCR:\Extensions\ContractId\Windows.Protocol\PackageId\Microsoft.XboxGameCallableUI_1000.16299.15.0_neutral_neutral_cw5n1h2txyewy"
               
        #Windows Share Target
        "HKCR:\Extensions\ContractId\Windows.ShareTarget\PackageId\ActiproSoftwareLLC.562882FEEB491_2.6.18.18_neutral__24pqs290vpjk0"
    )
        
    #This writes the output of each key it is removing and also removes the keys listed above.
    ForEach ($Key in $Keys) {
        Write-Output "Removing $Key from registry"
        Remove-Item $Key -Recurse
    }
}
            
Function Protect-Privacy {
            
    #Disables Windows Feedback Experience
    Write-Output "Disabling Windows Feedback Experience program"
    $Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (Test-Path $Advertising) {
        Set-ItemProperty $Advertising Enabled -Value 0 
    }
            
    #Stops Cortana from being used as part of your Windows Search Function
    Write-Output "Stopping Cortana from being used as part of your Windows Search Function"
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (Test-Path $Search) {
        Set-ItemProperty $Search AllowCortana -Value 0 
    }

    #Disables Web Search in Start Menu
    Write-Output "Disabling Bing Search in Start Menu"
    $WebSearch = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (!(Test-Path $WebSearch)) {
        New-Item $WebSearch
    }
    Set-ItemProperty $WebSearch DisableWebSearch -Value 1 
    #BingSearchEnabled is ignored on 22H2+, use DisableSearchBoxSuggestions instead
    $SearchExplorer = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    If (!(Test-Path $SearchExplorer)) {
        New-Item $SearchExplorer
    }
    Set-ItemProperty $SearchExplorer DisableSearchBoxSuggestions -Value 1
    #Also set BingSearchEnabled for older builds
    $SearchReg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
    If (Test-Path $SearchReg) {
        Set-ItemProperty $SearchReg BingSearchEnabled -Value 0
    }
            
    #Stops the Windows Feedback Experience from sending anonymous data
    Write-Output "Stopping the Windows Feedback Experience program"
    $Period = "HKCU:\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) { 
        New-Item $Period
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 0 

    #Prevents bloatware applications from returning and removes Start Menu suggestions               
    Write-Output "Adding Registry key to prevent bloatware apps from returning"
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    $registryOEM = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $registryPath)) { 
        New-Item $registryPath
    }
    Set-ItemProperty $registryPath DisableWindowsConsumerFeatures -Value 1 

    If (!(Test-Path $registryOEM)) {
        New-Item $registryOEM
    }
    Set-ItemProperty $registryOEM  ContentDeliveryAllowed -Value 0 
    Set-ItemProperty $registryOEM  OemPreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  PreInstalledAppsEverEnabled -Value 0 
    Set-ItemProperty $registryOEM  SilentInstalledAppsEnabled -Value 0 
    Set-ItemProperty $registryOEM  SystemPaneSuggestionsEnabled -Value 0          
    
    #Preping mixed Reality Portal for removal    
    Write-Output "Setting Mixed Reality Portal value to 0 so that you can uninstall it in Settings"
    $Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"    
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 0 
    }

    #Wi-Fi Sense was removed in Windows 10 version 1607 (Anniversary Update)
    #The AllowWiFiHotSpotReporting and AllowAutoConnectToWiFiSenseHotspots registry keys are obsolete
    Write-Output "Skipping Wi-Fi Sense (removed in version 1607)"
        

    #Turns off Data Collection via the AllowTelemetry key by changing it to 0
    Write-Output "Turning off Data Collection"
    $DataCollection1 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    $DataCollection2 = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    $DataCollection3 = "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Policies\DataCollection"    
    If (Test-Path $DataCollection1) {
        Set-ItemProperty $DataCollection1  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection2) {
        Set-ItemProperty $DataCollection2  AllowTelemetry -Value 0 
    }
    If (Test-Path $DataCollection3) {
        Set-ItemProperty $DataCollection3  AllowTelemetry -Value 0 
    }
    
    #Disabling Location Tracking
    Write-Output "Disabling Location Tracking"
    $SensorState = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}"
    $LocationConfig = "HKLM:\SYSTEM\CurrentControlSet\Services\lfsvc\Service\Configuration"
    If (!(Test-Path $SensorState)) {
        New-Item $SensorState
    }
    Set-ItemProperty $SensorState SensorPermissionState -Value 0 
    If (!(Test-Path $LocationConfig)) {
        New-Item $LocationConfig
    }
    Set-ItemProperty $LocationConfig Status -Value 0 
        
    #Disables People icon on Taskbar
    Write-Output "Disabling People icon on Taskbar"
    $People = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People'
    If (Test-Path $People) {
        Set-ItemProperty $People -Name PeopleBand -Value 0
    }
        
    #Disables scheduled tasks that are considered unnecessary 
    Write-Output "Disabling scheduled tasks"
    Get-ScheduledTask  Consolidator | Disable-ScheduledTask
    Get-ScheduledTask  UsbCeip | Disable-ScheduledTask

    #Additional telemetry tasks (Application Experience) - compatible with 22H2
    Write-Output "Disabling Application Experience telemetry tasks"
    Get-ScheduledTask "Microsoft Compatibility Appraiser" -ErrorAction SilentlyContinue | Disable-ScheduledTask
    Get-ScheduledTask "ProgramDataUpdater" -ErrorAction SilentlyContinue | Disable-ScheduledTask
    Get-ScheduledTask "Proxy" -TaskPath "\Microsoft\Windows\Autochk\" -ErrorAction SilentlyContinue | Disable-ScheduledTask

    Write-Output "Stopping and disabling Diagnostics Tracking Service"
    #Disabling the Diagnostics Tracking Service (Connected User Experiences and Telemetry)
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled


}

Function DisableCortana {
    Write-Host "Disabling Cortana"
    $Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 0 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 1 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 1 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 0
    
}

Function EnableCortana {
    Write-Host "Re-enabling Cortana"
    $Cortana1 = "HKCU:\SOFTWARE\Microsoft\Personalization\Settings"
    $Cortana2 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization"
    $Cortana3 = "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore"
    If (!(Test-Path $Cortana1)) {
        New-Item $Cortana1
    }
    Set-ItemProperty $Cortana1 AcceptedPrivacyPolicy -Value 1 
    If (!(Test-Path $Cortana2)) {
        New-Item $Cortana2
    }
    Set-ItemProperty $Cortana2 RestrictImplicitTextCollection -Value 0 
    Set-ItemProperty $Cortana2 RestrictImplicitInkCollection -Value 0 
    If (!(Test-Path $Cortana3)) {
        New-Item $Cortana3
    }
    Set-ItemProperty $Cortana3 HarvestContacts -Value 1 
}
        
Function Stop-EdgePDF {
    
    #Stops edge from taking over as the default .PDF viewer    
    Write-Output "Stopping Edge from taking over as the default .PDF viewer"
    $NoPDF = "HKCR:\.pdf"
    $NoProgids = "HKCR:\.pdf\OpenWithProgids"
    $NoWithList = "HKCR:\.pdf\OpenWithList" 
    If (!(Get-ItemProperty $NoPDF  NoOpenWith)) {
        New-ItemProperty $NoPDF NoOpenWith 
    }        
    If (!(Get-ItemProperty $NoPDF  NoStaticDefaultVerb)) {
        New-ItemProperty $NoPDF  NoStaticDefaultVerb 
    }        
    If (!(Get-ItemProperty $NoProgids  NoOpenWith)) {
        New-ItemProperty $NoProgids  NoOpenWith 
    }        
    If (!(Get-ItemProperty $NoProgids  NoStaticDefaultVerb)) {
        New-ItemProperty $NoProgids  NoStaticDefaultVerb 
    }        
    If (!(Get-ItemProperty $NoWithList  NoOpenWith)) {
        New-ItemProperty $NoWithList  NoOpenWith
    }        
    If (!(Get-ItemProperty $NoWithList  NoStaticDefaultVerb)) {
        New-ItemProperty $NoWithList  NoStaticDefaultVerb 
    }
            
    #Appends an underscore '_' to the Registry key for Edge
    $Edge = "HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_"
    If (Test-Path $Edge) {
        Set-Item $Edge AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_ 
    }
}

Function Revert-Changes {   
        
    #This function will revert the changes you made when running the Start-Debloat function.
        
    #This line reinstalls all of the bloatware that was removed
    Get-AppxPackage -AllUsers | ForEach {Add-AppxPackage -Verbose -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"} 
    
    #Tells Windows to enable your advertising information.    
    Write-Output "Re-enabling key to show advertisement information"
    $Advertising = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (Test-Path $Advertising) {
        Set-ItemProperty $Advertising  Enabled -Value 1
    }
            
    #Enables Cortana to be used as part of your Windows Search Function
    Write-Output "Re-enabling Cortana to be used in your Windows Search"
    $Search = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
    If (Test-Path $Search) {
        Set-ItemProperty $Search  AllowCortana -Value 1 
    }
            
    #Re-enables the Windows Feedback Experience for sending anonymous data
    Write-Output "Re-enabling Windows Feedback Experience"
    $Period = "HKCU:\Software\Microsoft\Siuf\Rules"
    If (!(Test-Path $Period)) { 
        New-Item $Period
    }
    Set-ItemProperty $Period PeriodInNanoSeconds -Value 1 
    
    #Enables bloatware applications               
    Write-Output "Adding Registry key to allow bloatware apps to return"
    $registryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    If (!(Test-Path $registryPath)) {
        New-Item $registryPath 
    }
    Set-ItemProperty $registryPath  DisableWindowsConsumerFeatures -Value 0 
        
    #Changes Mixed Reality Portal Key 'FirstRunSucceeded' to 1
    Write-Output "Setting Mixed Reality Portal value to 1"
    $Holo = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Holographic"
    If (Test-Path $Holo) {
        Set-ItemProperty $Holo  FirstRunSucceeded -Value 1 
    }
        
    #Re-enables live tiles
    Write-Output "Enabling live tiles"
    $Live = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CurrentVersion\PushNotifications"
    If (!(Test-Path $Live)) {
        New-Item $Live 
    }
    Set-ItemProperty $Live  NoTileApplicationNotification -Value 0 
       
    #Re-enables data collection
    Write-Output "Re-enabling data collection"
    $DataCollection = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection"
    If (!(Test-Path $DataCollection)) {
        New-Item $DataCollection
    }
    Set-ItemProperty $DataCollection  AllowTelemetry -Value 1
        
    #Re-enables People Icon on Taskbar
    Write-Output "Enabling People icon on Taskbar"
    $People = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced\People"
    If (!(Test-Path $People)) {
        New-Item $People 
    }
    Set-ItemProperty $People  PeopleBand -Value 1 
    
    #Re-enables suggestions on start menu
    Write-Output "Enabling suggestions on the Start Menu"
    $Suggestions = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    If (!(Test-Path $Suggestions)) {
        New-Item $Suggestions
    }
    Set-ItemProperty $Suggestions  SystemPaneSuggestionsEnabled -Value 1 
        
    #Re-enables scheduled tasks that were disabled when running the Debloat switch
    Write-Output "Enabling scheduled tasks that were disabled"
    Get-ScheduledTask XblGameSaveTaskLogon | Enable-ScheduledTask 
    Get-ScheduledTask  XblGameSaveTask | Enable-ScheduledTask 
    Get-ScheduledTask  Consolidator | Enable-ScheduledTask 
    Get-ScheduledTask  UsbCeip | Enable-ScheduledTask 
    Get-ScheduledTask  DmClient | Enable-ScheduledTask 
    Get-ScheduledTask  DmClientOnScenarioDownload | Enable-ScheduledTask 

    Write-Output "Re-enabling and starting WAP Push Service"
    #Enable and start WAP Push Service
    Set-Service "dmwappushservice" -StartupType Automatic
    Start-Service "dmwappushservice"
    
    Write-Output "Re-enabling and starting the Diagnostics Tracking Service"
    #Enabling the Diagnostics Tracking Service
    Set-Service "DiagTrack" -StartupType Automatic
    Start-Service "DiagTrack"
    
    Write-Output "Restoring 3D Objects in the 'My Computer' submenu in explorer"
    #Restoring 3D Objects in the 'My Computer' submenu in explorer
    Restore3dObjects
}

Function CheckDMWService {

    Param([switch]$Debloat)
  
    If (Get-Service -Name dmwappushservice | Where-Object {$_.StartType -eq "Disabled"}) {
        Set-Service -Name dmwappushservice -StartupType Automatic
    }

    If (Get-Service -Name dmwappushservice | Where-Object {$_.Status -eq "Stopped"}) {
        Start-Service -Name dmwappushservice
    } 
}
    
Function Enable-EdgePDF {
    Write-Output "Setting Edge back to default"
    $NoPDF = "HKCR:\.pdf"
    $NoProgids = "HKCR:\.pdf\OpenWithProgids"
    $NoWithList = "HKCR:\.pdf\OpenWithList"
    #Sets edge back to default
    If (Get-ItemProperty $NoPDF  NoOpenWith) {
        Remove-ItemProperty $NoPDF  NoOpenWith
    } 
    If (Get-ItemProperty $NoPDF  NoStaticDefaultVerb) {
        Remove-ItemProperty $NoPDF  NoStaticDefaultVerb 
    }       
    If (Get-ItemProperty $NoProgids  NoOpenWith) {
        Remove-ItemProperty $NoProgids  NoOpenWith 
    }        
    If (Get-ItemProperty $NoProgids  NoStaticDefaultVerb) {
        Remove-ItemProperty $NoProgids  NoStaticDefaultVerb 
    }        
    If (Get-ItemProperty $NoWithList  NoOpenWith) {
        Remove-ItemProperty $NoWithList  NoOpenWith
    }    
    If (Get-ItemProperty $NoWithList  NoStaticDefaultVerb) {
        Remove-ItemProperty $NoWithList  NoStaticDefaultVerb
    }
        
    #Removes an underscore '_' from the Registry key for Edge
    $Edge2 = "HKCR:\AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723_"
    If (Test-Path $Edge2) {
        Set-Item $Edge2 AppXd4nrz8ff68srnhf9t5a8sbjyar1cr723
    }
}

Function FixWhitelistedApps {
    
    #Credit to abulgatz for these lines of code
    $WhitelistedAppsToFix = @(
        "Microsoft.WindowsCalculator"
        "Microsoft.WindowsStore"
        "Microsoft.Windows.Photos"
        "Microsoft.ScreenSketch"
        "Microsoft.WindowsCamera"
    )
    ForEach ($App in $WhitelistedAppsToFix) {
        If (!(Get-AppxPackage -Name $App)) {
            Get-AppxPackage -AllUsers $App | ForEach { Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml" }
        }
    }
}

Function UnpinStart {
    # https://superuser.com/a/1442733
    #Requires -RunAsAdministrator

$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@

    $layoutFile="C:\Windows\StartMenuLayout.xml"

    #Delete layout file if it already exists
    If(Test-Path $layoutFile)
    {
        Remove-Item $layoutFile
    }

    #Creates the blank layout file
    $START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII

    $regAliases = @("HKLM", "HKCU")

    #Assign the start layout and force it to apply with "LockedStartLayout" at both the machine and user level
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        IF(!(Test-Path -Path $keyPath)) { 
            New-Item -Path $basePath -Name "Explorer"
        }
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
        Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
    }

    #Restart Explorer, open the start menu (necessary to load the new layout), and give it a few seconds to process
    Stop-Process -name explorer
    Start-Sleep -s 5
    $wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
    Start-Sleep -s 5

    #Enable the ability to pin items again by disabling "LockedStartLayout"
    foreach ($regAlias in $regAliases){
        $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
        $keyPath = $basePath + "\Explorer" 
        Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
    }

    #Restart Explorer and delete the layout file
    Stop-Process -name explorer

    # Uncomment the next line to make clean start menu default for all new users
    #Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\

    Remove-Item $layoutFile
}

Function Remove3dObjects {
    #Removes 3D Objects from the 'My Computer' submenu in explorer
    Write-Host "Removing 3D Objects from explorer 'My Computer' submenu"
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    If (Test-Path $Objects32) {
        Remove-Item $Objects32 -Recurse 
    }
    If (Test-Path $Objects64) {
        Remove-Item $Objects64 -Recurse 
    }
}

Function Restore3dObjects {
    #Restores 3D Objects from the 'My Computer' submenu in explorer
    Write-Host "Restoring 3D Objects from explorer 'My Computer' submenu"
    $Objects32 = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    $Objects64 = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}"
    If (!(Test-Path $Objects32)) {
        New-Item $Objects32
    }
    If (!(Test-Path $Objects64)) {
        New-Item $Objects64
    }
}

#Function DisableLastUsedFilesAndFolders {
#	Write-Host = "Disable Explorer to show last used files and folders."
#	Invoke-Item (start powershell ((Split-Path $MyInvocation.InvocationName) + "\Individual Scripts\Disable Last Used Files and Folders View.ps1"))
#}

Function DisableDiagTrack {
    Write-Host "Stopping and disabling Diagnostics Tracking Service"
    Stop-Service "DiagTrack"
    Set-Service "DiagTrack" -StartupType Disabled
}

Function DisableWAPPush {
    Write-Host "Stopping and disabling WAP Push Service"
    Stop-Service "dmwappushservice"
    Set-Service "dmwappushservice" -StartupType Disabled
}

Function DisableWindowsUpdate {
    Write-Host "Disabling Windows Update services..."
    Stop-Service -Name wuauserv -ErrorAction SilentlyContinue
    Set-Service -Name wuauserv -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name WaaSMedicSvc -ErrorAction SilentlyContinue
    Set-Service -Name WaaSMedicSvc -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name UsoSvc -ErrorAction SilentlyContinue
    Set-Service -Name UsoSvc -StartupType Disabled -ErrorAction SilentlyContinue
    Write-Host "Windows Update services disabled."
}

Function EnableWindowsUpdate {
    Write-Host "Enabling Windows Update services..."
    Set-Service -Name wuauserv -StartupType Manual -ErrorAction SilentlyContinue
    Start-Service -Name wuauserv -ErrorAction SilentlyContinue
    Set-Service -Name WaaSMedicSvc -StartupType Manual -ErrorAction SilentlyContinue
    Start-Service -Name WaaSMedicSvc -ErrorAction SilentlyContinue
    Set-Service -Name UsoSvc -StartupType Manual -ErrorAction SilentlyContinue
    Start-Service -Name UsoSvc -ErrorAction SilentlyContinue
    Write-Host "Windows Update services restored."
}

#Interactive prompt Debloat/Revert options
$Button = [Windows.MessageBoxButton]::YesNoCancel
$ErrorIco = [Windows.MessageBoxImage]::Error
$Warn = [Windows.MessageBoxImage]::Warning
$Ask = 'The following will allow you to either Debloat Windows 10 or to revert changes made after Debloating Windows 10.

        Select "Yes" to Debloat Windows 10

        Select "No" to Revert changes made by this script
        
        Select "Cancel" to stop the script.'

$EverythingorSpecific = "Would you like to remove everything that was preinstalled on your Windows Machine? Select Yes to remove everything, or select No to remove apps via a blacklist."
$EdgePdf = "Do you want to stop edge from taking over as the default PDF viewer?"
$EdgePdf2 = "Do you want to revert changes that disabled Edge as the default PDF viewer?"
$Reboot = "For some of the changes to properly take effect it is recommended to reboot your machine. Would you like to restart?"
$OneDriveDelete = "Do you want to uninstall One Drive?"
$Unpin = "Do you want to unpin all items from the Start menu?"
$InstallNET = "Do you want to install .NET 3.5?"
$LastUsedFilesFolders = "Do you want to hide last used files and folders in Explorer?"
$LastUsedFilesFolders2 = "Do you want to show last used files and folders in Explorer?"
$ClearLastUsedFilesFolders = "Do you want to clear last used files and folders?"
$DisableWinUpdate = "Do you want to disable Windows Update?"
$EnableWinUpdate = "Do you want to re-enable Windows Update? (Recommended)"
$AeroShake = "Do you want to disable AeroShake?"
$AeroShake2 = "Do you want to re-enable AeroShake?"
# Run safety checks before proceeding
If (Get-Command Run-SafetyChecks -ErrorAction SilentlyContinue) {
    Try {
        Run-SafetyChecks
    } Catch {
        Log-Error -Message "Safety checks failed: $($_.Exception.Message)" -Source "Windows10Debloater.ps1"
        Exit
    }
}

$Prompt1 = [Windows.MessageBox]::Show($Ask, "Debloat or Revert", $Button, $ErrorIco) 
Switch ($Prompt1) {
    #This will debloat Windows 10
    Yes {
        #Everything is specific prompt
        $Prompt2 = [Windows.MessageBox]::Show($EverythingorSpecific, "Everything or Specific", $Button, $Warn)
        switch ($Prompt2) {
            Yes { 
                #Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
                Write-Host "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the removal and modification of specific registry keys."
                New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
                Start-Sleep 1
                Write-Host "Uninstalling bloatware, please wait."
                DebloatAll
                Write-Host "Bloatware removed."
                Start-Sleep 1
                Write-Host "Removing specific registry keys."
                Remove-Keys
                Write-Host "Leftover bloatware registry keys removed."
                Start-Sleep 1
                Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
                Start-Sleep 1
                FixWhitelistedApps
                Start-Sleep 1
                Write-Host "Disabling Cortana from search, disabling feedback to Microsoft, and disabling scheduled tasks that are considered to be telemetry or unnecessary."
                Protect-Privacy
                Start-Sleep 1
                DisableCortana
                Write-Host "Cortana disabled and removed from search, feedback to Microsoft has been disabled, and scheduled tasks are disabled."
                Start-Sleep 1
                Write-Host "Stopping and disabling Diagnostics Tracking Service"
                DisableDiagTrack
                Write-Host "Diagnostics Tracking Service disabled"
                Start-Sleep 1
                Write-Host "Disabling WAP push service"
                DisableWAPPush
                Start-Sleep 1
                Write-Host "Re-enabling DMWAppushservice if it was disabled"
                CheckDMWService
                Start-Sleep 1
                Write-Host "Removing 3D Objects from the 'My Computer' submenu in explorer"
                Remove3dObjects
                Start-Sleep 1
            }
            No {
                #Creates a "drive" to access the HKCR (HKEY_CLASSES_ROOT)
                Write-Host "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the removal and modification of specific registry keys."
                New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
                Start-Sleep 1
                Write-Host "Uninstalling bloatware, please wait."
                DebloatBlacklist
                Write-Host "Bloatware removed."
                Start-Sleep 1
                Write-Host "Removing specific registry keys."
                Remove-Keys
                Write-Host "Leftover bloatware registry keys removed."
                Start-Sleep 1
                Write-Host "Checking to see if any Whitelisted Apps were removed, and if so re-adding them."
                Start-Sleep 1
                FixWhitelistedApps
                Start-Sleep 1
                Write-Host "Disabling Cortana from search, disabling feedback to Microsoft, and disabling scheduled tasks that are considered to be telemetry or unnecessary."
                Protect-Privacy
                Start-Sleep 1
                DisableCortana
                Write-Host "Cortana disabled and removed from search, feedback to Microsoft has been disabled, and scheduled tasks are disabled."
                Start-Sleep 1
                Write-Host "Stopping and disabling Diagnostics Tracking Service"
                DisableDiagTrack
                Write-Host "Diagnostics Tracking Service disabled"
                Start-Sleep 1
                Write-Host "Disabling WAP push service"
                Start-Sleep 1
                DisableWAPPush
                Write-Host "Re-enabling DMWAppushservice if it was disabled"
                CheckDMWService
                Start-Sleep 1
            }
        }
        #Disabling EdgePDF prompt
        $Prompt3 = [Windows.MessageBox]::Show($EdgePdf, "Edge PDF", $Button, $Warn)
        Switch ($Prompt3) {
            Yes {
                Stop-EdgePDF
                Write-Host "Edge will no longer take over as the default PDF viewer."
            }
            No {
                Write-Host "You chose not to stop Edge from taking over as the default PDF viewer."
            }
        }
        #Prompt asking to delete OneDrive
        $Prompt4 = [Windows.MessageBox]::Show($OneDriveDelete, "Delete OneDrive", $Button, $ErrorIco) 
        Switch ($Prompt4) {
            Yes {
                UninstallOneDrive
                Write-Host "OneDrive is now removed from the computer."
            }
            No {
                Write-Host "You have chosen to skip removing OneDrive from your machine."
            }
        }
        #Prompt asking if you'd like to unpin all start items
        $Prompt5 = [Windows.MessageBox]::Show($Unpin, "Unpin", $Button, $ErrorIco) 
        Switch ($Prompt5) {
            Yes {
                UnpinStart
                Write-Host "Start Apps unpinned."
            }
            No {
                Write-Host "Apps will remain pinned to the start menu."

            }
        }
        #Prompt asking if you want to install .NET
        $Prompt6 = [Windows.MessageBox]::Show($InstallNET, "Install .Net", $Button, $Warn)
        Switch ($Prompt6) {
            Yes {
                Write-Host "Initializing the installation of .NET 3.5..."
                DISM /Online /Enable-Feature /FeatureName:NetFx3 /All
                Write-Host ".NET 3.5 has been successfully installed!"
            }
            No {
                Write-Host "Skipping .NET install."
            }
        }

        #Prompt asking to disable Windows Update
        $PromptWU = [Windows.MessageBox]::Show($DisableWinUpdate, "Disable Windows Update", $Button, $Warn)
        Switch ($PromptWU) {
            Yes {
                DisableWindowsUpdate
            }
            No {
                Write-Host "Skipping Disable Windows Update."
            }
        }
#		#Prompt asking if you want to deactivate Last Used Files and Folders
#        $Prompt7 = [Windows.MessageBox]::Show($LastUsedFilesFolders, "Deactivate Last Used Files and Folders", $Button, $Warn)
#        Switch ($Prompt7) {
#            Yes {
#                DisableLastUsedFilesAndFolders
#                Write-Host "Last Used Files and Folders will no longer been shown!"
#            }
#            No {
#                Write-Host "Skipping Hiding Last used Files and Folders."
#            }
#        }
		
        #Prompt asking if you'd like to reboot your machine
        $Prompt0 = [Windows.MessageBox]::Show($Reboot, "Reboot", $Button, $Warn)
        Switch ($Prompt0) {
            Yes {
                Write-Host "Unloading the HKCR drive..."
                Remove-PSDrive HKCR 
                Start-Sleep 1
                Write-Host "Initiating reboot."
                Stop-Transcript
                Start-Sleep 2
                Restart-Computer
            }
            No {
                Write-Host "Unloading the HKCR drive..."
                Remove-PSDrive HKCR 
                Start-Sleep 1
                Write-Host "Script has finished. Exiting."
                Stop-Transcript
                Start-Sleep 2
                Exit
            }
        }
    }
    No {
        Write-Host "Reverting changes..."
        Write-Host "Creating PSDrive 'HKCR' (HKEY_CLASSES_ROOT). This will be used for the duration of the script as it is necessary for the modification of specific registry keys."
        New-PSDrive  HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        Revert-Changes
        #Prompt asking to revert edge changes as well
        $Prompt6 = [Windows.MessageBox]::Show($EdgePdf2, "Revert Edge", $Button, $ErrorIco)
        Switch ($Prompt6) {
            Yes {
                Enable-EdgePDF
                Write-Host "Edge will no longer be disabled from being used as the default Edge PDF viewer."
            }
            No {
                Write-Host "You have chosen to keep the setting that disallows Edge to be the default PDF viewer."
            }
        }

        #Prompt asking to enable Windows Update
        $PromptWU = [Windows.MessageBox]::Show($EnableWinUpdate, "Enable Windows Update", $Button, $Warn)
        Switch ($PromptWU) {
            Yes {
                EnableWindowsUpdate
            }
            No {
                Write-Host "Skipping Enable Windows Update."
            }
        }
        #Prompt asking if you'd like to reboot your machine
        $Prompt0 = [Windows.MessageBox]::Show($Reboot, "Reboot", $Button, $Warn)
        Switch ($Prompt0) {
            Yes {
                Write-Host "Unloading the HKCR drive..."
                Remove-PSDrive HKCR 
                Start-Sleep 1
                Write-Host "Initiating reboot."
                Stop-Transcript
                Start-Sleep 2
                Restart-Computer
            }
            No {
                Write-Host "Unloading the HKCR drive..."
                Remove-PSDrive HKCR 
                Start-Sleep 1
                Write-Host "Script has finished. Exiting."
                Stop-Transcript
                Start-Sleep 2
                Exit
            }
        }
    }
}


