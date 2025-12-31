Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$script:IsBusy = $false

# ---------- FONTS ----------
$LabelFont = New-Object System.Drawing.Font(
    "Segoe UI",
    10,
    [System.Drawing.FontStyle]::Regular
)
$ButtonFont = New-Object System.Drawing.Font(
    "Segoe UI",
    10,
    [System.Drawing.FontStyle]::Regular
)

# Paths
$BasePath = "$env:LOCALAPPDATA\Obscure\Saved"
$SaveGamesPath = Join-Path $BasePath "SaveGames"
$GameProcessName = "ChooChooCharles-Win64-Shipping"


# ---------- SAFETY ----------
function Game-Is-Running {
    return Get-Process -Name $GameProcessName -ErrorAction SilentlyContinue
}

function Ensure-Game-Closed {
    if (Game-Is-Running) {
        [System.Windows.Forms.MessageBox]::Show(
            "Choo-Choo Charles is currently running.`n`nPlease close the game before continuing.",
            "Game Running",
            "OK",
            "Warning"
        )
        return $false
    }
    return $true
}

# ---------- FILE HELPERS ----------
function Clear-Folder($Path) {
    if (Test-Path $Path) {
        Get-ChildItem $Path -Force | Remove-Item -Recurse -Force
    }
}


function Backup-SaveGames($SlotPath) {
    if (!(Test-Path $SlotPath)) {
        New-Item -ItemType Directory -Path $SlotPath | Out-Null
    }

    # Clear slot folder first (no duplicates)
    Clear-Folder $SlotPath

    if (Test-Path $SaveGamesPath) {
        Copy-Item "$SaveGamesPath\*" $SlotPath -Recurse -Force -ErrorAction SilentlyContinue
    }
}
function Restore-SaveGames($SlotPath) {
    Clear-Folder $SaveGamesPath

    if (!(Test-Path $SlotPath)) { return }

    Copy-Item "$SlotPath\*" $SaveGamesPath -Recurse -Force -ErrorAction SilentlyContinue
}

function Write-APInfo($SlotName, $APSlotName) {
    if ([string]::IsNullOrWhiteSpace($APSlotName)) { return }

    $infoPath = Join-Path $BasePath "$SlotName AP Info.txt"

    $content = @"
Save Slot: $SlotName
Archipelago Slot: $APSlotName
Last Updated: $(Get-Date)
"@

    $content | Set-Content $infoPath -Force
}

# ---------- GUI ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "Choo-Choo Charles Save Slot Manager"
$form.Size = New-Object System.Drawing.Size(520,380)
$form.StartPosition = "CenterScreen"

# Prevent closing while file ops are running
$form.Add_FormClosing({
    if ($script:IsBusy) {
        [System.Windows.Forms.MessageBox]::Show(
            "Files are still being transferred. Please wait for it to finish.",
            "Working...",
            "OK",
            "Warning"
        )
        $_.Cancel = $true
    }
})

$panelMain   = New-Object System.Windows.Forms.Panel
$panelCreate = New-Object System.Windows.Forms.Panel
$panelSwap   = New-Object System.Windows.Forms.Panel

$panelMain.Dock = $panelCreate.Dock = $panelSwap.Dock = "Fill"
$panelCreate.Visible = $false
$panelSwap.Visible   = $false

# --- Create layout ---
$createLayout = New-Object System.Windows.Forms.TableLayoutPanel
$createLayout.Dock = "Fill"
$createLayout.Padding = New-Object System.Windows.Forms.Padding(10)
$createLayout.ColumnCount = 1
$createLayout.AutoSize = $true
$createLayout.AutoSizeMode = "GrowAndShrink"
$createLayout.RowStyles.Clear()
$createLayout.ColumnStyles.Clear()
[void]$createLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$createLayout.GrowStyle = "AddRows"

# --- Swap layout ---
$swapLayout = New-Object System.Windows.Forms.TableLayoutPanel
$swapLayout.Dock = "Fill"
$swapLayout.Padding = New-Object System.Windows.Forms.Padding(10)
$swapLayout.ColumnCount = 1
$swapLayout.AutoSize = $true
$swapLayout.AutoSizeMode = "GrowAndShrink"
$swapLayout.RowStyles.Clear()
$swapLayout.ColumnStyles.Clear()
[void]$swapLayout.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle([System.Windows.Forms.SizeType]::Percent, 100)))
$swapLayout.GrowStyle = "AddRows"

# Put layouts inside their panels
$panelCreate.Controls.Add($createLayout)
$panelSwap.Controls.Add($swapLayout)

# Put panels on the form (important!)
[void]$form.Controls.AddRange(@($panelMain, $panelCreate, $panelSwap))

# ---------- MAIN MENU ----------
$btnCreate = New-Object System.Windows.Forms.Button
$btnCreate.Text = "Create / Backup Save Slot"
$btnCreate.Size = "260,40"
$btnCreate.Location = "100,60"
$btnCreate.Font = $ButtonFont

$btnSwap = New-Object System.Windows.Forms.Button
$btnSwap.Text = "Swap Save Slots"
$btnSwap.Size = "260,40"
$btnSwap.Location = "100,120"
$btnSwap.Font = $ButtonFont

$btnOpenFolder = New-Object System.Windows.Forms.Button
$btnOpenFolder.Text = "Open Save Folder"
$btnOpenFolder.Size = "260,40"
$btnOpenFolder.Location = "100,180"
$btnOpenFolder.Font = $ButtonFont

$panelMain.Controls.AddRange(@($btnCreate,$btnSwap,$btnOpenFolder))

# ---------- CREATE ----------
$lblSlot = New-Object System.Windows.Forms.Label
$lblSlot.Text = "Save slot folder name:"
$lblSlot.AutoSize = $true
$lblSlot.Font = $LabelFont
$lblSlot.Margin = New-Object System.Windows.Forms.Padding(0,0,0,2)

$txtSlot = New-Object System.Windows.Forms.TextBox
$txtSlot.Dock = "Fill"
$txtSlot.Margin = New-Object System.Windows.Forms.Padding(0,0,0,10)

$lblAPSlot = New-Object System.Windows.Forms.Label
$lblAPSlot.Text = "Archipelago slot name (optional):"
$lblAPSlot.AutoSize = $true
$lblAPSlot.Font = $LabelFont
$lblAPSlot.Margin = New-Object System.Windows.Forms.Padding(0,0,0,2)

$txtAPSlot = New-Object System.Windows.Forms.TextBox
$txtAPSlot.Dock = "Fill"
$txtAPSlot.Margin = New-Object System.Windows.Forms.Padding(0,0,0,10)

$chkBackup = New-Object System.Windows.Forms.CheckBox
$chkBackup.Text = "Backup SaveGames folder"
$chkBackup.Checked = $false
$chkBackup.AutoSize = $true
$chkBackup.Font = $LabelFont
$chkBackup.Margin = New-Object System.Windows.Forms.Padding(0,0,0,6)

$chkDelete = New-Object System.Windows.Forms.CheckBox
$chkDelete.Text = "Delete SaveGames after backup"
$chkDelete.AutoSize = $true
$chkDelete.Font = $LabelFont
$chkDelete.Margin = New-Object System.Windows.Forms.Padding(0,0,0,14)

# Buttons row as a FlowLayoutPanel (so they line up nicely)
$createButtons = New-Object System.Windows.Forms.FlowLayoutPanel
$createButtons.FlowDirection = "LeftToRight"
$createButtons.AutoSize = $true
$createButtons.Margin = New-Object System.Windows.Forms.Padding(0,0,0,0)
$createButtons.Dock = "Left"
$createButtons.Padding = New-Object System.Windows.Forms.Padding(0)
$createButtons.WrapContents = $false

$btnBack1 = New-Object System.Windows.Forms.Button
$btnBack1.Text = "Back"
$btnBack1.Size = New-Object System.Drawing.Size(100,30)
$btnBack1.Font = $ButtonFont

$btnRunCreate = New-Object System.Windows.Forms.Button
$btnRunCreate.Text = "Run"
$btnRunCreate.Size = New-Object System.Drawing.Size(100,30)
$btnRunCreate.Font = $ButtonFont

$createButtons.Controls.AddRange(@($btnBack1,$btnRunCreate))

# Clear and add to layout
$createLayout.Controls.Clear()
$createLayout.Controls.Add($lblSlot)
$createLayout.Controls.Add($txtSlot)
$createLayout.Controls.Add($lblAPSlot)
$createLayout.Controls.Add($txtAPSlot)
$createLayout.Controls.Add($chkBackup)
$createLayout.Controls.Add($chkDelete)
$createLayout.Controls.Add($createButtons)

$createLayout.RowStyles.Clear()
for ($i=0; $i -lt $createLayout.Controls.Count; $i++) {
    [void]$createLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
}

# ---------- SWAP ----------
$lblActive = New-Object System.Windows.Forms.Label
$lblActive.Text = "Currently active slot:"
$lblActive.AutoSize = $true
$lblActive.Font = $LabelFont
$lblActive.Margin = New-Object System.Windows.Forms.Padding(0,0,0,2)

$cmbActive = New-Object System.Windows.Forms.ComboBox
$cmbActive.Dock = "Fill"
$cmbActive.DropDownStyle = "DropDownList"
$cmbActive.Margin = New-Object System.Windows.Forms.Padding(0,0,0,10)

$lblTarget = New-Object System.Windows.Forms.Label
$lblTarget.Text = "Slot to load:"
$lblTarget.AutoSize = $true
$lblTarget.Font = $LabelFont
$lblTarget.Margin = New-Object System.Windows.Forms.Padding(0,0,0,2)

$cmbTarget = New-Object System.Windows.Forms.ComboBox
$cmbTarget.Dock = "Fill"
$cmbTarget.DropDownStyle = "DropDownList"
$cmbTarget.Margin = New-Object System.Windows.Forms.Padding(0,0,0,14)

# Buttons row
$swapButtons = New-Object System.Windows.Forms.FlowLayoutPanel
$swapButtons.FlowDirection = "LeftToRight"
$swapButtons.AutoSize = $true
$swapButtons.Margin = New-Object System.Windows.Forms.Padding(0,0,0,0)
$swapButtons.Dock = "Left"
$swapButtons.Padding = New-Object System.Windows.Forms.Padding(0)
$swapButtons.WrapContents = $false

$btnBack2 = New-Object System.Windows.Forms.Button
$btnBack2.Text = "Back"
$btnBack2.Size = New-Object System.Drawing.Size(100,30)
$btnBack2.Font = $ButtonFont

$btnRunSwap = New-Object System.Windows.Forms.Button
$btnRunSwap.Text = "Swap"
$btnRunSwap.Size = New-Object System.Drawing.Size(100,30)
$btnRunSwap.Font = $ButtonFont

$swapButtons.Controls.AddRange(@($btnBack2,$btnRunSwap))

# Clear and add to layout
$swapLayout.Controls.Clear()
$swapLayout.Controls.Add($lblActive)
$swapLayout.Controls.Add($cmbActive)
$swapLayout.Controls.Add($lblTarget)
$swapLayout.Controls.Add($cmbTarget)
$swapLayout.Controls.Add($swapButtons)

$swapLayout.RowStyles.Clear()
for ($i=0; $i -lt $swapLayout.Controls.Count; $i++) {
    [void]$swapLayout.RowStyles.Add((New-Object System.Windows.Forms.RowStyle([System.Windows.Forms.SizeType]::AutoSize)))
}

# ---------- EVENTS ----------
$btnBack1.Add_Click({
    $panelCreate.Visible = $false
    $panelMain.Visible   = $true
})

$btnBack2.Add_Click({
    $panelSwap.Visible = $false
    $panelMain.Visible = $true
})

$btnCreate.Add_Click({
    if (!(Ensure-Game-Closed)) { return }
    $panelMain.Visible = $false
    $panelCreate.Visible = $true
})

$btnSwap.Add_Click({
    if (!(Ensure-Game-Closed)) { return }

    $cmbActive.Items.Clear()
    $cmbTarget.Items.Clear()

    Get-ChildItem $BasePath -Directory |
        Where-Object { $_.Name -ne "SaveGames" } |
        ForEach-Object {
            $cmbActive.Items.Add($_.Name)
            $cmbTarget.Items.Add($_.Name)
        }

    $panelMain.Visible = $false
    $panelSwap.Visible = $true
})

$btnOpenFolder.Add_Click({
    if (Test-Path $BasePath) {
        Start-Process explorer.exe $BasePath
    }
    else {
        [System.Windows.Forms.MessageBox]::Show(
            "Save folder not found:`n$BasePath",
            "Folder Not Found",
            "OK",
            "Error"
        )
    }
})

$btnRunCreate.Add_Click({

    if ([string]::IsNullOrWhiteSpace($txtSlot.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Slot name required.")
        return
    }

    # ----- BUSY START -----
    $script:IsBusy = $true
    $form.UseWaitCursor = $true
    $form.Enabled = $false
    # ----------------------

    try {
        $slotName = $txtSlot.Text.Trim()
        $slotPath = Join-Path $BasePath $slotName

        if (!(Test-Path $slotPath)) {
            New-Item -ItemType Directory -Path $slotPath | Out-Null
        }

        if ($chkBackup.Checked) {
            Backup-SaveGames $slotPath
        }

        Write-APInfo $slotName $txtAPSlot.Text

        if ($chkDelete.Checked) {
            Clear-Folder $SaveGamesPath
        }

        [System.Windows.Forms.MessageBox]::Show("Slot process complete.")
		
		# Clear fields + reset options (stay on Create screen)
		$txtSlot.Clear()
		$txtAPSlot.Clear()
		$chkBackup.Checked = $false
		$chkDelete.Checked = $false
		$txtSlot.Focus()

    }
    finally {
        # ----- BUSY END -----
        $form.Enabled = $true
        $form.UseWaitCursor = $false
        $script:IsBusy = $false
        # -------------------
    }
})
$btnRunSwap.Add_Click({

    if (!$cmbActive.SelectedItem -or !$cmbTarget.SelectedItem) {
        [System.Windows.Forms.MessageBox]::Show("Select both slots.")
        return
    }

    # ----- BUSY START -----
    $script:IsBusy = $true
    $form.UseWaitCursor = $true
    $form.Enabled = $false
    # ----------------------

    try {
        Backup-SaveGames (Join-Path $BasePath $cmbActive.SelectedItem)
        Restore-SaveGames (Join-Path $BasePath $cmbTarget.SelectedItem)

        [System.Windows.Forms.MessageBox]::Show("Slot swap complete.")
        $panelSwap.Visible = $false
        $panelMain.Visible = $true
    }
    finally {
        # ----- BUSY END -----
        $form.Enabled = $true
        $form.UseWaitCursor = $false
        $script:IsBusy = $false
        # -------------------
    }
})

[void]$form.ShowDialog()
