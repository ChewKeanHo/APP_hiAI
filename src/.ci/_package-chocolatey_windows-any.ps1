# Copyright 2023 (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at:
#               http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.




# initialize
if (-not (Test-Path -Path $env:PROJECT_PATH_ROOT)) {
	Write-Error "[ ERROR ] - Please run from automataCI\ci.sh.ps1 instead!`n"
	exit 1
}

. "${env:LIBS_AUTOMATACI}\services\io\fs.ps1"
. "${env:LIBS_AUTOMATACI}\services\i18n\translations.ps1"




function PACKAGE-Assemble-CHOCOLATEY-Content {
	param (
		[string]$_target,
		[string]$_directory,
		[string]$_target_name,
		[string]$_target_os,
		[string]$_target_arch
	)


	# validate project
	if ($(FS-Is-Target-A-Chocolatey "${_target}") -ne 0) {
		return 10 # not applicable
	}


	# assemble the package
	$___source = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_BUILD}\${env:PROJECT_SKU}_windows-amd64.sh.ps1"
	$___dest = "${_directory}\bin\${env:PROJECT_SKU_TITLECASE}.sh.ps1"
	$null = I18N-Assemble "${___source}" "${___dest}"
	$null = FS-Make-Housing-Directory "${___dest}"
	$___process = FS-Copy-File "${___source}" "${___dest}"
	if ($___process -ne 0) {
		$null = I18N-Assemble-Failed
		return 1
	}

	$___source = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_SOURCE}\icons\icon-128x128.png"
	$___dest = "${_directory}\icon.png"
	$null = I18N-Assemble "${___source}" "${___dest}"
	$___process = FS-Copy-File "${___source}" "${___dest}"
	if ($___process -ne 0) {
		$null = I18N-Assemble-Failed
		return 1
	}

	$___source = "${env:PROJECT_PATH_ROOT}\README.md"
	$___dest = "${_directory}\README.md"
	$null = I18N-Assemble "${___source}" "${___dest}"
	$___process = FS-Copy-File "${___source}" "${___dest}"
	if ($___process -ne 0) {
		$null = I18N-Assemble-Failed
		return 1
	}


	# REQUIRED: chocolatey required tools\ directory
	$___dest = "${_directory}\tools"
	$null = I18N-Create "${___dest}"
	$___process = FS-Make-Directory "${___dest}"
	if ($___process -ne 0) {
		$null = I18N-Create-Failed
		return 1
	}


	# OPTIONAL: chocolatey tools\chocolateyBeforeModify.ps1
	$___dest = "${_directory}\tools\chocolateyBeforeModify.ps1"
	$null = I18N-Create "${___dest}"
	$___process = FS-Write-File "${___dest}" @"
Write-Host "Performing pre-configurations..."
"@
	if ($___process -ne 0) {
		$null = I18N-Create-Failed
		return 1
	}


	# REQUIRED: chocolatey tools\chocolateyinstall.ps1
	$___dest = "${_directory}\tools\chocolateyinstall.ps1"
	$null = I18N-Create "${___dest}"
	$___process = FS-Write-File "${___dest}" @"
Write-Host "Uninstalling ${env:PROJECT_SKU_TITLECASE} (${env:PROJECT_VERSION})..."
"@
	if ($___process -ne 0) {
		$null = I18N-Create-Failed
		return 1
	}


	# REQUIRED: chocolatey tools\chocolateyuninstall.ps1
	$___dest = "${_directory}\tools\chocolateyuninstall.ps1"
	$null = I18N-Create "${___dest}"
	$___process = FS-Write-File "${___dest}" @"
# REQUIRED - PREPARING UNINSTALLATION
Write-Host "Uninstalling ${env:PROJECT_SKU_TITLECASE} (${env:PROJECT_VERSION})..."
"@
	if ($___process -ne 0) {
		$null = I18N-Create-Failed
		return 1
	}


	# REQUIRED: chocolatey xml.nuspec file
	$___dest = "${_directory}\${env:PROJECT_SKU}.nuspec"
	$null = I18N-Create "${___dest}"
	$___process = FS-Write-File "${___dest}" @"
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://schemas.microsoft.com/packaging/2015/06/nuspec.xsd">
	<metadata>
		<id>${env:PROJECT_SKU}</id>
		<title>${env:PROJECT_NAME}</title>
		<version>${env:PROJECT_VERSION}</version>
		<authors>${env:PROJECT_CONTACT_NAME}</authors>
		<owners>${env:PROJECT_CONTACT_NAME}</owners>
		<projectUrl>${env:PROJECT_CONTACT_WEBSITE}</projectUrl>
		<license type="expression">${env:PROJECT_LICENSE}</license>
		<description>${env:PROJECT_PITCH}</description>
		<readme>README.md</readme>
		<icon>icon.png</icon>
	</metadata>
	<dependencies>
		<dependency id="chocolatey" version="0.9.8.21" />
	</dependencies>
	<files>
		<file src="README.md" target="README.md" />
		<file src="icon.png" target="icon.png" />
		<file src="bin\**" target="Data" />
		<file src="tools\**" target="tools" />
	</files>
</package>
"@
	if ($___process -ne 0) {
		$null = I18N-Create-Failed
		return 1
	}


	# report status
	return 0
}
