# Script to install basic programs on newly deployed device

# Ensuring that we have winget/ in case it's corrupted this way it should work
Add-AppxPackage -Path "https://aka.ms/getwinget"

# Hardcoded list of applications 
$apps =@(
    "VideoLAN.VLC",
    "RARLab.WinRAR",
    "Adobe.Acrobat.Reader.64-bit",
    "Google.Chrome"
    "TeamViewer.TeamViewer"
)
# Looping through each package to install
foreach ($app in $apps) {
    Write-Output "Installing $app..."
    winget install $app -e --accept-package-agreements --silent
    Write-Output "$app installation completed!"
}