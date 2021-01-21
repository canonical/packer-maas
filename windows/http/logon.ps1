<#
# Upstream Author:
#
#     Canonical Ltd.
#
# Copyright:
#
#     (c) 2014-2017 Canonical Ltd.
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
            $webclient = New-Object System.Net.WebClient
            $wdksetup = [IO.Path]::GetFullPath("$ENV:TEMP\wdksetup.exe")
            $wdkurl = "http://download.microsoft.com/download/0/8/C/08C7497F-8551-4054-97DE-60C0E510D97A/wdk/wdksetup.exe"
            $webclient.DownloadFile($wdkurl, $wdksetup)

            # Run the installer.
            $Host.UI.RawUI.WindowTitle = "Installing Windows Driver Kit..."
            $p = Start-Process -PassThru -Wait -FilePath "$wdksetup" -ArgumentList "/features OptionId.WindowsDriverKitComplete /q /ceip off /norestart"
            if ($p.ExitCode -ne 0)
            {
                throw "Installing $wdksetup failed."
            }

            # Run dpinst.exe with the path to the drivers.
            $Host.UI.RawUI.WindowTitle = "Injecting Windows drivers..."
            $dpinst = "$programFilesDir\Windows Kits\8.1\redist\DIFx\dpinst\EngMui\$archDir\dpinst.exe"
            Start-Process -Wait -FilePath "$dpinst" -ArgumentList "/S /C /F /SA /Path E:\infs"

            # Uninstall the WDK
            $Host.UI.RawUI.WindowTitle = "Uninstalling Windows Driver Kit..."
            Start-Process -Wait -FilePath "$wdksetup" -ArgumentList "/features + /q /uninstall /norestart"
        }

        $Host.UI.RawUI.WindowTitle = "Installing Cloudbase-Init..."
    	wget "https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi" -outfile "c:\cloudbase.msi"
        $cloudbaseInitPath = "c:\cloudbase.msi"
        $cloudbaseInitLog = "$ENV:Temp\cloudbase_init.log"
        $serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
        $p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/i $cloudbaseInitPath /qn /norestart /l*v $cloudbaseInitLog LOGGINGSERIALPORTNAME=$serialPortName"
        if ($p.ExitCode -ne 0)
        {
            throw "Installing $cloudbaseInitPath failed. Log: $cloudbaseInitLog"
        }

        if (Test-Path -Path "E:\cloudbase\cloudbase_init.zip")
        {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            New-Item -Path "$ENV:TEMP\cloudbase-init" -Type directory
            [System.IO.Compression.ZipFile]::ExtractToDirectory("E:\cloudbase\cloudbase_init.zip", "$ENV:TEMP\cloudbase-init")

            Remove-Item -Recurse -Force "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\Python\Lib\site-packages\cloudbaseinit"
            Copy-Item -Recurse -Path "$ENV:TEMP\cloudbase-init\cloudbaseinit" -Destination "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\Python\Lib\site-packages\"
        }

    	# install virtio drivers
        certutil -addstore "TrustedPublisher" A:/rh.cer
    	[Net.ServicePointManager]::SecurityProtocol = "Tls, Tls11, Tls12, Ssl3"
    	wget "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.185-2/virtio-win-gt-x64.msi" -outfile "c:\virtio.msi"
    	wget "https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/archive-virtio/virtio-win-0.1.185-2/virtio-win-guest-tools.exe" -outfile "c:\virtio.exe"
    	$virtioPath = "c:\virtio.msi"
        $virtioLog = "$ENV:Temp\virtio.log"
        $serialPortName = @(Get-WmiObject Win32_SerialPort)[0].DeviceId
        $p = Start-Process -Wait -PassThru -FilePath msiexec -ArgumentList "/a $virtioPath /qn /quiet /norestart /l*v $virtioLog LOGGINGSERIALPORTNAME=$serialPortName"
	    Start-Process -Wait -FilePath C:\virtio.exe -Argument "/silent" -PassThru


        # We're done, remove LogonScript, disable AutoLogon
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name Unattend*
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoLogonCount


        $Host.UI.RawUI.WindowTitle = "Running SetSetupComplete..."
        & "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\bin\SetSetupComplete.cmd"

        # Write success, this is used to check that this process made it this far
        New-Item -Path C:\success.tch -Type file -Force

        if ($RunPowershell) {
            $Host.UI.RawUI.WindowTitle = "Paused, waiting for user to finish work in other terminal"
            Write-Host "Spawning another powershell for the user to complete any work..."
            Start-Process -Wait -PassThru -FilePath powershell
        }

        $Host.UI.RawUI.WindowTitle = "Running Sysprep..."
        $unattendedXmlPath = "$ENV:ProgramFiles\Cloudbase Solutions\Cloudbase-Init\conf\Unattend.xml"
        & "$ENV:SystemRoot\System32\Sysprep\Sysprep.exe" `/generalize `/oobe `/shutdown `/unattend:"$unattendedXmlPath"
        stop-computer
    
}
catch
{
    $_ | Out-File C:\error_log.txt
}
