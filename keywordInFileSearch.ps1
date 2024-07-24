# Script to look through text based files for certain keywords, good for logs

# Import necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form and the rest of the visuals
$form = New-Object System.Windows.Forms.Form
$form.Text = "Keyword Search in Files"
$form.Size = New-Object System.Drawing.Size(550, 400)

$labelFolderPath = New-Object System.Windows.Forms.Label
$labelFolderPath.Text = "Folder Path:"
$labelFolderPath.Location = New-Object System.Drawing.Point(10, 20)
$labelFolderPath.Size = New-Object System.Drawing.Size(100, 20)
$form.Controls.Add($labelFolderPath)

$textboxFolderPath = New-Object System.Windows.Forms.TextBox
$textboxFolderPath.Location = New-Object System.Drawing.Point(120, 20)
$textboxFolderPath.Size = New-Object System.Drawing.Size(200, 20)
$form.Controls.Add($textboxFolderPath)

$buttonBrowse = New-Object System.Windows.Forms.Button
$buttonBrowse.Text = "Browse"
$buttonBrowse.Location = New-Object System.Drawing.Point(330, 20)
$form.Controls.Add($buttonBrowse)

$labelKeywords = New-Object System.Windows.Forms.Label
$labelKeywords.Text = "Keywords (comma separated):"
$labelKeywords.Location = New-Object System.Drawing.Point(10, 60)
$labelKeywords.Size = New-Object System.Drawing.Size(150, 60)
$form.Controls.Add($labelKeywords)

$textboxKeywords = New-Object System.Windows.Forms.TextBox
$textboxKeywords.Location = New-Object System.Drawing.Point(170, 60)
$textboxKeywords.Size = New-Object System.Drawing.Size(150, 20)
$form.Controls.Add($textboxKeywords)

$buttonSearch = New-Object System.Windows.Forms.Button
$buttonSearch.Text = "Search"
$buttonSearch.Location = New-Object System.Drawing.Point(150, 100)
$form.Controls.Add($buttonSearch)

$listboxResults = New-Object System.Windows.Forms.ListBox
$listboxResults.Location = New-Object System.Drawing.Point(10, 140)
$listboxResults.Size = New-Object System.Drawing.Size(500, 200)
$form.Controls.Add($listboxResults)

# Button handler for browsing for file
$buttonBrowse.Add_Click({
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $textboxFolderPath.Text = $folderBrowser.SelectedPath
    }
})

# Button to brows for the keywords in files
$buttonSearch.Add_Click({
    $folderPath = $textboxFolderPath.Text
    $keywords = $textboxKeywords.Text -split ",\s*"
    $listboxResults.Items.Clear()

    if (-not (Test-Path $folderPath)) {
        [System.Windows.Forms.MessageBox]::Show("Invalid folder path", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $files = Get-ChildItem -Path $folderPath -Recurse -File
    foreach ($file in $files) {
        $content = Get-Content -Path $file.FullName -Raw
        foreach ($keyword in $keywords) {
            if ($content -match $keyword) {
                $result = "File: $($file.FullName) | Keyword: $keyword"
                $listboxResults.Items.Add($result)
            }
        }
    }

    if ($listboxResults.Items.Count -eq 0) {
        $listboxResults.Items.Add("No matches found.")
    }
})
# Handler to open the found file on double click
$listboxResults.Add_DoubleClick({
    $selectedItem = $listboxResults.SelectedItem
    if ($selectedItem -and ($selectedItem -match "File: (.+?) \|")) {
        $filePath = $matches[1]
        Start-Process -FilePath $filePath
    }
})

$form.ShowDialog()
