$ErrorActionPreference = 'Stop'
$Root = Split-Path $PSScriptRoot -Parent
$Files = @(Get-ChildItem $Root -Filter '*.ps1') + @(Get-ChildItem (Join-Path $Root 'Individual Scripts') -File)
foreach ($File in $Files) {
    $Tokens = $null
    $Errors = $null
    $Ast = [System.Management.Automation.Language.Parser]::ParseFile($File.FullName, [ref]$Tokens, [ref]$Errors)
    if ($Errors) { throw "$($File.Name): $($Errors -join '; ')" }
    # Compile the literal protection patterns without executing the scripts.
    $Assignments = $Ast.FindAll({ param($Node)
        $Node -is [System.Management.Automation.Language.AssignmentStatementAst]
    }, $true)
    foreach ($Assignment in $Assignments) {
        if ($Assignment.Left.Extent.Text -match '(WhitelistedApps|NonRemovable)$') {
            $Literal = $Assignment.Right.Extent.Text
            if ($Literal.StartsWith("'")) {
                $Pattern = [regex]::new($Literal.Trim("'"))
                if (!$Pattern.IsMatch('Microsoft.WindowsStore') -and !$Pattern.IsMatch('Microsoft.Windows.ShellExperienceHost')) {
                    throw "Protection pattern does not protect expected packages in $($File.Name)"
                }
            }
        }
    }
}
. (Join-Path $Root 'StabilityFunctions.ps1')
# Mock Windows commands: validate restore-point success and throttle handling without changing the host.
$script:Created = $false
function Get-ComputerRestorePoint {
    [pscustomobject]@{ SequenceNumber = 1; Description = 'Existing' }
    if ($script:Created) { [pscustomobject]@{ SequenceNumber = 2; Description = 'Test' } }
}
function Checkpoint-Computer { $script:Created = $true }
function Read-Host { throw 'Unexpected confirmation requested' }
Create-RestorePoint -Description 'Test'
$script:Created = $false
function Checkpoint-Computer { }
$Rejected = $false
try { Create-RestorePoint -Description 'Test' } catch { $Rejected = $true }
if (!$Rejected) { throw 'A skipped restore point was incorrectly reported as successful.' }
# Ensure installer failures do not report success.
function Test-Path { $true }
function Stop-Process { }
function Start-Process { [pscustomobject]@{ ExitCode = 5 } }
$Rejected = $false
try { UninstallOneDrive } catch { $Rejected = $true }
if (!$Rejected) { throw 'A failed OneDrive uninstaller was accepted.' }
Write-Host 'Parsing and safety regression checks passed.'
