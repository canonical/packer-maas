<#
# Upstream Author:
#
#     Canonical Ltd.
#
# Copyright:
#
#     (c) 2014-2023 Canonical Ltd.
#
# Licence:
#
# If you have an executed agreement with a Canonical group company which
# includes a licence to this software, your use of this software is governed
# by that agreement.  Otherwise, the following applies:
#
# Canonical Ltd. hereby grants to you a world-wide, non-exclusive,
# non-transferable, revocable, perpetual (unless revoked) licence, to (i) use
# this software in connection with Canonical's MAAS software to install Windows
# in non-production environments and (ii) to make a reasonable number of copies
# of this software for backup and installation purposes.  You may not: use,
# copy, modify, disassemble, decompile, reverse engineer, or distribute the
# software except as expressly permitted in this licence; permit access to the
# software to any third party other than those acting on your behalf; or use
# this software in connection with a production environment.
#
# CANONICAL LTD. MAKES THIS SOFTWARE AVAILABLE "AS-IS".  CANONICAL  LTD. MAKES
# NO REPRESENTATIONS OR WARRANTIES OF ANY KIND, WHETHER ORAL OR WRITTEN,
# WHETHER EXPRESS, IMPLIED, OR ARISING BY STATUTE, CUSTOM, COURSE OF DEALING
# OR TRADE USAGE, WITH RESPECT TO THIS SOFTWARE.  CANONICAL LTD. SPECIFICALLY
# DISCLAIMS ANY AND ALL IMPLIED WARRANTIES OR CONDITIONS OF TITLE, SATISFACTORY
# QUALITY, MERCHANTABILITY, SATISFACTORINESS, FITNESS FOR A PARTICULAR PURPOSE
# AND NON-INFRINGEMENT.
#
# IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL
# CANONICAL LTD. OR ANY OF ITS AFFILIATES, BE LIABLE TO YOU FOR DAMAGES,
# INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
# OUT OF THE USE OR INABILITY TO USE THIS SOFTWARE (INCLUDING BUT NOT LIMITED
# TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU
# OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
# PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGES.
#>

param(
    [Parameter()]
    [switch]$RunPowershell
)

$ErrorActionPreference = "Stop"

try
{
    # Need to have network connection to continue, wait 30
    # seconds for the network to be active.
    start-sleep -s 30

        # Inject extra drivers if the infs directory is present on the attached iso
        if (Test-Path -Path "E:\infs")
        {
            # To install extra drivers the Windows Driver Kit is needed for dpinst.exe.
            # Sadly you cannot just download dpinst.exe. The whole driver kit must be
            # installed.
            # Download the WDK installer.
            $Host.UI.RawUI.WindowTitle = "Downloading Windows Driver Kit..."
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest "https://download.microsoft.com/download/8/6/9/86925F0F-D57A-4BA4-8278-861B6876D78E/wdk/wdksetup.exe" -Outfile "c:\wdksetup.exe"

            # Run the installer.
            $Host.UI.RawUI.WindowTitle = "Installing Windows Driver Kit..."
            $p = Start-Process -PassThru -Wait -FilePath "c:\wdksetup.exe" -ArgumentList "/features OptionId.WindowsDriverKitComplete /q /ceip off /norestart"
            if ($p.ExitCode -ne 0)
            {
                throw "Installing wdksetup.exe failed."
            }

            # Run dpinst.exe with the path to the drivers.
            $Host.UI.RawUI.WindowTitle = "Injecting Windows drivers..."
            $dpinst = "$ENV:ProgramFiles (x86)\Windows Kits\8.1\redist\DIFx\dpinst\EngMui\x64\dpinst.exe"
            Start-Process -Wait -FilePath "$dpinst" -ArgumentList "/S /C /F /SA /Path E:\infs"

            # Uninstall the WDK
            $Host.UI.RawUI.WindowTitle = "Uninstalling Windows Driver Kit..."
            Start-Process -Wait -FilePath "c:\wdksetup.exe" -ArgumentList "/features + /q /uninstall /norestart"

            # Clean-up
            Remove-Item -Path c:\wdksetup.exe
        }

        $Host.UI.RawUI.WindowTitle = "Installing Cloudbase-Init..."
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest "https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi" -Outfile "c:\cloudbase.msi"
        $cloudbaseInitLog = "$ENV:Temp\cloudbase_init.log"
        $serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
        $p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/i c:\cloudbase.msi /qn /norestart /l*v $cloudbaseInitLog LOGGINGSERIALPORTNAME=$serialPortName"
        if ($p.ExitCode -ne 0)
        {
            throw "Installing $cloudbaseInitPath failed. Log: $cloudbaseInitLog"
        }

        # Install virtio drivers
        $Host.UI.RawUI.WindowTitle = "Installing Virtio Drivers..."
        certutil -addstore "TrustedPublisher" A:/rh.cer
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win-gt-x64.msi" -Outfile "c:\virtio.msi"
        Invoke-WebRequest "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win-guest-tools.exe" -Outfile "c:\virtio.exe"
        $virtioLog = "$ENV:Temp\virtio.log"
        $serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
        $p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/a c:\virtio.msi /qn /norestart /l*v $virtioLog LOGGINGSERIALPORTNAME=$serialPortName"
        $p = Start-Process -Wait -PassThru -FilePath c:\virtio.exe -Argument "/silent"

        # We're done, remove LogonScript, disable AutoLogon
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount

        $Host.UI.RawUI.WindowTitle = "Running SetSetupComplete..."
        & "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"

        if ($RunPowershell) {
            $Host.UI.RawUI.WindowTitle = "Paused, waiting for user to finish work in other terminal"
            Write-Host "Spawning another powershell for the user to complete any work..."
            Start-Process -Wait -PassThru -FilePath powershell
        }

        # Clean-up
        Remove-Item -Path c:\cloudbase.msi
        Remove-Item -Path c:\virtio.msi
        Remove-Item -Path c:\virtio.exe

        # Write success, this is used to check that this process made it this far
        New-Item -Path c:\success.tch -Type file -Force

        $Host.UI.RawUI.WindowTitle = "Running Sysprep..."
        $unattendedXmlPath = "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
        & "$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/shutdown `/unattend:"$unattendedXmlPath"
}
catch
{
    $_ | Out-File c:\error_log.txt
}
