# Load the required assemblies and ensure winget is present/not corrupted
#Add-AppxPackage -Path "https://aka.ms/getwinget"
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Management.Automation


# Define the applications and their winget identifiers
$applications = @{
    "VideoLAN VLC" = "VideoLAN.VLC";
    "RARLab WinRAR" = "RARLab.WinRAR";
    "Adobe Acrobat Reader" = "Adobe.Acrobat.Reader.64-bit";
    "Google Chrome" = "Google.Chrome";
    "TeamViewer Client" = "TeamViewer.TeamViewer"
    "Mozilla Firefox" = "Mozilla.Firefox";
    "Microsoft Teams" = "Microsoft.Teams";
    "Skype" = "Skype.Skype";
    "KeePass" = "DominikReichl.KeePass";
    "Notepad++" = "Notepad++.Notepad++";
    "WinSCP" = "WinSCP.WinSCP";
    "Dell SupportAssist" = "Dell.SupportAssist";
}

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Application Installer"
$form.Size = New-Object System.Drawing.Size(600, 300)
$form.StartPosition = "CenterScreen"

# Create a panel to hold the checkboxes
$panel = New-Object System.Windows.Forms.Panel
$panel.Size = New-Object System.Drawing.Size(600, 200)
$panel.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($panel)

# Create the checkboxes
$checkboxes = @{}
$y = 10
$x = 10
foreach ($app in $applications.Keys) {
    $checkbox = New-Object System.Windows.Forms.CheckBox
    $checkbox.Text = $app
    $checkbox.Location = New-Object System.Drawing.Point($x, $y)
    $checkbox.AutoSize = $true
    $panel.Controls.Add($checkbox)
    $checkboxes[$app] = $checkbox
    $y += 30
    if($y -ge 190){
        $x += 200
        $y = 10
    }
}

# Create the Install button
$buttonInstall = New-Object System.Windows.Forms.Button
$buttonInstall.Text = "Install"
$buttonInstall.Location = New-Object System.Drawing.Point(250, 220)
$form.Controls.Add($buttonInstall)

# Create the Test button
$buttonAll = New-Object System.Windows.Forms.Button
$buttonAll.Text = "All"
$buttonAll.Location = New-Object System.Drawing.Point(350, 220)
$form.Controls.Add($buttonAll)

# Add event handler for the button
$buttonInstall.Add_Click({
    $selectedApps = @()
    foreach ($app in $applications.Keys) {
        if ($checkboxes[$app].Checked) {
            $selectedApps += $applications[$app]
        }
    }
    if ($selectedApps.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("Please select at least one application to install.")
    } else {
        foreach ($app in $selectedApps) {
            [System.Windows.Forms.MessageBox]::Show("$app is being installed. Please wait...")
            # Start-Process -FilePath "winget" -ArgumentList "install $app --accept-package-agreements --silent" -NoNewWindow -Wait
            winget install $app -e --accept-package-agreements --silent
        }
        [System.Windows.Forms.MessageBox]::Show("Selected applications have been installed.")
    }
})
$buttonAll.Add_Click({
    foreach($app in $applications.Keys){
        $checkboxes[$app].Checked = $true
    }
})

# Show the form
$form.Add_Shown({$form.Activate()})
[void] $form.ShowDialog()
