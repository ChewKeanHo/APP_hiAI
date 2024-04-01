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
. "${env:LIBS_AUTOMATACI}\services\io\strings.ps1"
. "${env:LIBS_AUTOMATACI}\services\i18n\translations.ps1"




function PACKAGE-Assemble-HOMEBREW-Content {
	param (
		[string]$_target,
		[string]$_directory,
		[string]$_target_name,
		[string]$_target_os,
		[string]$_target_arch
	)


	# validate project
	if ($(FS-Is-Target-A-Homebrew "${_target}") -ne 0) {
		return 10 # not applicable
	}


	# assemble the package
	$___source = "${env:PROJECT_PATH_ROOT}\${env:PROJECT_PATH_BUILD}\${env:PROJECT_SKU}_darwin-amd64.sh.ps1"
	$___dest = "${_directory}\bin\${env:PROJECT_SKU_TITLECASE}"
	$null = I18N-Assemble "${___source}" "${___dest}"
	$null = FS-Make-Housing-Directory "${___dest}"
	$___process = FS-Copy-File "${___source}" "${___dest}"
	if ($___process -ne 0) {
		$null = I18N-Assemble-Failed
		return 1
	}


	# script formula.rb
	$___dest = "${_directory}\formula.rb"
	$null = I18N-Create "${___dest}"
	$___process = FS-Write-File "${___dest}" @"
class $(STRINGS-To-Uppercase-First-Char "${env:PROJECT_SKU_TITLECASE}") < Formula
  desc "${env:PROJECT_PITCH}"
  homepage "${env:PROJECT_CONTACT_WEBSITE}"
  license "${env:PROJECT_LICENSE}"
  url "${env:PROJECT_HOMEBREW_SOURCE_URL}/{{ TARGET_PACKAGE }}"
  sha256 "{{ TARGET_SHASUM }}"


  def install
    chmod 0755, "bin/${env:PROJECT_SKU_TITLECASE}"
    libexec.install "bin/${env:PROJECT_SKU_TITLECASE}"
    bin.install_symlink libexec/"${env:PROJECT_SKU_TITLECASE}" => "${env:PROJECT_SKU_TITLECASE}"
  end

  test do
    assert_predicate ./bin/${env:PROJECT_SKU_TITLECASE}, :exist?
  end
end
"@
	if ($___process -ne 0) {
		$null = I18N-Create-Failed
		return 1
	}


	# report status
	return 0
}
