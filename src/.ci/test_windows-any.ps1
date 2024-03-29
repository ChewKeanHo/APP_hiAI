# Copyright 2024 (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
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

. "${env:LIBS_AUTOMATACI}\services\io\os.ps1"
. "${env:LIBS_AUTOMATACI}\services\io\fs.ps1"
. "${env:LIBS_AUTOMATACI}\services\io\net\http.ps1"
. "${env:LIBS_AUTOMATACI}\services\i18n\translations.ps1"




# execute
$null = I18N-Activate-Environment
$___process = OS-Is-Command-Available "curl"
if ($___process -ne 0) {
	$null = I18N-Activate-Failed
	return 1
}


$___source = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_SOURCE}\main.ps1"
$___workspace = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_TEMP}\test_hiAI"
$null = FS-Remake-Directory "${___workspace}"


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
$null = Set-Item -Path "env:GOOGLEAI_API_TOKEN" -Value "Some_Dummy_Value"
$___process = OS-Exec "powershell" @"
-noprofile -executionpolicy bypass -Command "& ${___source} --config ${___config} --text2text "What are you?"
"@
if ($___process -ne 0) {
	$null = I18N-Test-Failed
	return 1
}




# report status
return 0
