<#	
	.NOTES
	===========================================================================
	 Created with: 	PowerShellGUI
	 Created on:   	28/01/2020 1:12 PM
	 Created by:   	Kiren James
	 Organization: 	Atom Inc
	 Filename:     	network-printer-add.ps1
	===========================================================================
	.DESCRIPTION
		A script to select and add printer server network printers on windows domain clients
#>
$printers = Get-Printer -ComputerName inf-printer-srv | where Shared -eq true | Select-Object Name,ComputerName

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Connect Network Printers'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,30)
$label.Text = 'Please select the drives to connect (Use Ctrl key for multiple selection):'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.Listbox
$listBox.Location = New-Object System.Drawing.Point(10,50)
$listBox.Size = New-Object System.Drawing.Size(260,20)

$listBox.SelectionMode = 'MultiExtended'

foreach ($printer in $printers) {
	[void] $listBox.Items.Add($printer.Name)
}

$listBox.Height = 70
$form.Controls.Add($listBox)
$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
	Write-Output "Adding Printers..."
	for ( $i = 0; $i -lt $listBox.SelectedItems.Count; $i++ ) {
		switch($listBox.SelectedItems[$i])
		{
			$listBox.SelectedItems[$i] {
				foreach ($printer in $printers) {
					if ( $listBox.SelectedItems[$i] -eq $printer.Name ) {
						$printer.Name
						[void](Add-Printer -ConnectionName "\\$($printer.ComputerName)\$($printer.Name)");
						"Installation is done silently and will take awhile. Your kind patience would be of virtue.."
					}
				}
				break
			};		
		}
	}
}
cmd /c Pause