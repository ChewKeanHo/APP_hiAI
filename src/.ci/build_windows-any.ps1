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
	return 1
}

. "${env:LIBS_AUTOMATACI}\services\io\fs.ps1"
. "${env:LIBS_AUTOMATACI}\services\i18n\translations.ps1"
. "${env:LIBS_AUTOMATACI}\services\compilers\changelog.ps1"




# execute
$null = I18N-Check-Availability "CHANGELOG"
$___process = CHANGELOG-Is-Available
if ($___process -ne 0) {
	$null = I18N-Check-Failed
	return 1
}




# assemble polygot script
$___workspace = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_TEMP}\build-${env:PROJECT_SKU_TITLECASE}"
$null = FS-Remake-Directory "${___workspace}"


$___dest = "${___workspace}\${env:PROJECT_SKU_TITLECASE}.sh.ps1"
$null = I18N-Create "${___dest}"
$___process = FS-Write-File "${___dest}" @"
echo \" <<'RUN_AS_BATCH' >/dev/null ">NUL "\" \``" <#"
@ECHO OFF
REM LICENSE CLAUSES HERE
REM ----------------------------------------------------------------------------




REM ############################################################################
REM # Windows BATCH Codes                                                      #
REM ############################################################################
where /q powershell
if errorlevel 1 (
        echo "ERROR: missing powershell facility."
        exit /b 1
)

copy /Y "%~nx0" "%~n0.ps1" >nul
timeout /t 1 /nobreak >nul
powershell -executionpolicy remotesigned -Command "& '.\%~n0.ps1' %*"
start /b "" cmd /c del "%~f0" & exit /b %errorcode%
REM ############################################################################
REM # Windows BATCH Codes                                                      #
REM ############################################################################
RUN_AS_BATCH
#> | Out-Null




echo \" <<'RUN_AS_POWERSHELL' >/dev/null # " | Out-Null
################################################################################
# Windows POWERSHELL Codes                                                     #
################################################################################
"@
if ($___process -ne 0) {
	$null = I18N-Create-Failed
	return 1
}

## append src/main.ps1
foreach ($__line in (Get-Content "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_SOURCE}\main.ps1")) {
	$___process = STRINGS-Is-Empty "${__line}"
	if ($___process -eq 0) {
		continue
	}

	$null = Add-Content -Path $___dest -Value $__line
}

## to posix shell header
$___process = FS-Append-File "${___dest}" @"
################################################################################
# Windows POWERSHELL Codes                                                     #
################################################################################
exit
<#
RUN_AS_POWERSHELL




################################################################################
# Unix Main Codes                                                              #
################################################################################
"@
if ($___process -ne 0) {
	$null = I18N-Create-Failed
	return 1
}

## append src/main.sh
foreach ($__line in (Get-Content "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_SOURCE}\main.sh")) {
	$___process = STRINGS-Is-Empty "${__line}"
	if ($___process -eq 0) {
		continue
	}

	$null = Add-Content -Path $___dest -Value $__line
}

## close
$___process = FS-Append-File "${___dest}" @"
################################################################################
# Unix Main Codes                                                              #
################################################################################
exit `$?
#>
"@
if ($___process -ne 0) {
	$null = I18N-Create-Failed
	return 1
}

$___process = FS-Is-File "${___dest}"
if ($___process -ne 0) {
	$null = I18N-Create-Failed
	return 1
}

## test
$___source = "${___dest}"

$null = I18N-Test "${___source} --help"
$___process = OS-Exec "powershell" @"
-noprofile -executionpolicy bypass -Command "& ${___source} --help"
"@
if ($___process -ne 0) {
	$null = I18N-Test-Failed
	return 1
}

$___config = "${___workspace}\CONFIG.toml"
$null = I18N-Test "${___source} --create-config ${___config}"
$___process = OS-Exec "powershell" @"
-noprofile -executionpolicy bypass -Command "& ${___source} --create-config ${___config}"
"@
if ($___process -ne 0) {
	$null = I18N-Test-Failed
	return 1
}

$___process = FS-Is-File "${___config}"
if ($___process -ne 0) {
	$null = I18N-Test-Failed
	return 1
}

$null = I18N-Test "${___source} --text2text"
$null = I18N-Newline
$null = I18N-Newline
$null = Set-Item -Path "env:GOOGLEAI_API_TOKEN" -Value "Some_Dummy_Value"
$___process = OS-Exec "powershell" @"
-noprofile -executionpolicy bypass -Command "& ${___source} --config ${___config} --text2text "What are you?"
"@
if ($___process -ne 0) {
	$null = I18N-Test-Failed
	return 1
}
$null = I18N-Newline
$null = I18N-Newline




# export
$___dest = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_BUILD}\${env:PROJECT_SKU_TITLECASE}_any-any.sh.ps1"
$null = FS-Make-Housing-Directory "${___dest}"

$null = I18N-Export "${___dest}"
$___process = FS-Copy-File "${___source}" "${___dest}"
if ($___process -ne 0) {
	$null = I18N-Export-Failed
	return 1
}




# build changelog entries
$__file = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_SOURCE}\changelog"
$null = I18N-Create "${env:PROJECT_VERSION} DATA CHANGELOG"
$___process = CHANGELOG-Build-DATA-Entry $__file
if ($___process -ne 0) {
	$null = I18N-Create-Failed
	return 1
}


$null = I18N-Create "${env:PROJECT_VERSION} DEB CHANGELOG"
$___process = CHANGELOG-Build-DEB-Entry `
	"${__file}" `
	"$env:PROJECT_VERSION" `
	"$env:PROJECT_SKU" `
	"$env:PROJECT_DEBIAN_DISTRIBUTION" `
	"$env:PROJECT_DEBIAN_URGENCY" `
	"$env:PROJECT_CONTACT_NAME" `
	"$env:PROJECT_CONTACT_EMAIL" `
	(Get-Date -Format 'R')
if ($___process -ne 0) {
	$null = I18N-Create-Failed
	return 1
}




# report status
return 0
