# Copyright 2024 (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy
# of the License at:
#                 http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
function Status-Tag-Create {
	param(
		[string]$___content,
		[string]$___spacing
	)


	# validate input
	if ($(STRINGS-Is-Empty "${___content}") -eq 0) {
		return ""
	}


	# execute
	return "⦗${___content}⦘${___spacing}"
}




function Status-Tag-Get-Type {
	param(
		[string]$___mode
	)


	# execute (REMEMBER: make sure the text and spacing are having the same length)
	switch ($___mode) {
	error {
		return Status-Tag-Create " ERROR " "   "
	} warning {
		return Status-Tag-Create " WARNING " " "
	} info {
		return Status-Tag-Create " INFO " "    "
	} note {
		return Status-Tag-Create " NOTE " "    "
	} success {
		return Status-Tag-Create " SUCCESS " " "
	} ok {
		return Status-Tag-Create " OK " "      "
	} done {
		return Status-Tag-Create " DONE " "    "
	} default {
		return ""
	}}
}




function Print-Status {
	param(
		[string]$___mode,
		[string]$___message
	)


	# execute
	$___tag = Status-Tag-Get-Type "${___mode}"
	$___color = ""
	$___foreground_color = "Gray"
	switch ($___mode) {
	error {
		$___color = "31"
		$___foreground_color = "Red"
	} warning {
		$___color = "33"
		$___foreground_color = "Yellow"
	} info {
		$___color = "36"
		$___foreground_color = "Cyan"
	} note {
		$___color = "35"
		$___foreground_color = "Magenta"
	} success {
		$___color = "32"
		$___foreground_color = "Green"
	} ok {
		$___color = "36"
		$___foreground_color = "Cyan"
	} done {
		$___color = "36"
		$___foreground_color = "Cyan"
	} default {
		# do nothing
	}}

	if (($Host.UI.RawUI.ForegroundColor -ge "DarkGray") -or
		("$env:TERM" -eq "xterm-256color") -or
		("$env:COLORTERM" -eq "truecolor", "24bit")) {
		# terminal supports color mode
		if ((-not ([string]::IsNullOrEmpty($___color))) -and
			(-not ([string]::IsNullOrEmpty($___foreground_color)))) {
			$null = Write-Host `
				-NoNewLine `
				-ForegroundColor $___foreground_color `
				"$([char]0x1b)[1;${___color}m${___tag}$([char]0x1b)[0;${___color}m${___message}$([char]0x1b)[0m"
		} else {
			$null = Write-Host -NoNewLine "${___tag}${___message}"
		}
	} else {
		$null = Write-Host -NoNewLine "${___tag}${___message}"
	}

	$null = Remove-Variable -Name ___mode -ErrorAction SilentlyContinue
	$null = Remove-Variable -Name ___tag -ErrorAction SilentlyContinue
	$null = Remove-Variable -Name ___message -ErrorAction SilentlyContinue
	$null = Remove-Variable -Name ___color -ErrorAction SilentlyContinue
	$null = Remove-Variable -Name ___foreground_color -ErrorAction SilentlyContinue


	# report status
	return 0
}




function OS-Is-Command-Available {
	param (
		[string]$___command
	)


	# validate input
	if ([string]::IsNullOrEmpty($___command)) {
		return 1
	}


	# execute
	$__program = Get-Command $___command -ErrorAction SilentlyContinue
	if ($__program) {
		return 0
	}


	# report status
	return 1
}




function FS-Is-Directory {
	param (
		[string]$___target
	)


	# validate input
	if ([string]::IsNullOrEmpty($___target)) {
		return 1
	}


	# execute
	if (Test-Path -Path "${___target}" -PathType Container -ErrorAction SilentlyContinue) {
		return 0
	}


	# report status
	return 1
}




function FS-Is-File {
	param (
		[string]$___target
	)


	# validate input
	if ([string]::IsNullOrEmpty($___target)) {
		return 1
	}


	# execute
	$___process = FS-Is-Directory "${___target}"
	if ($___process -eq 0) {
		return 1
	}

	if (Test-Path -Path "${___target}" -ErrorAction SilentlyContinue) {
		return 0
	}


	# report status
	return 1
}




function FS-Make-Housing-Directory {
	param (
		[string]$___target
	)


	# validate input
	if ([string]::IsNullOrEmpty($___target)) {
		return 1
	}

	$___process = FS-Is-Directory $___target
	if ($___process -eq 0) {
		return 0
	}


	# perform create
	$___process = New-Item -ItemType Directory -Force `
		-Path "$(Split-Path -Parent -Path $___target)"
	if ($___process) {
		return 0
	}


	# report status
	return 1
}




function FS-Write-File {
	param (
		[string]$___target,
		[string]$___content
	)


	# validate input
	if ([string]::IsNullOrEmpty($___target)) {
		return 1
	}

	$___process = FS-Is-File "${___target}"
	if ($___process -eq 0) {
		return 1
	}


	# perform file write
	$null = Set-Content -Path $___target -Value $___content
	if ($?) {
		return 0
	}


	# report status
	return 1
}




function STRINGS-Is-Empty {
	param(
		$___target
	)


	# execute
	if ([string]::IsNullOrEmpty($___target)) {
		return 0
	}


	# report status
	return 1
}




function GOOGLEAI-Gemini-Query-Text-To-Text() {
	param(
		[string]$___query
	)


	# validate input
	if ($(STRINGS-Is-Empty "${___query}") -eq 0) {
		return 1
	}

	$___process = GOOGLEAI-Is-Available
	if ($___process -ne 0) {
		return 1
	}


	# configure
	if ($(STRINGS-Is-Empty "${env:GOOGLEAI_BLOCK_HATE_SPEECH}") -eq 0) {
		${env:GOOGLEAI_BLOCK_HATE_SPEECH} = "BLOCK_NONE"
	}

	if ($(STRINGS-Is-Empty "${GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT}") -eq 0) {
		${GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT} = "BLOCK_NONE"
	}

	if ($(STRINGS-Is-Empty "${GOOGLEAI_BLOCK_DANGEROUS_CONTENT}") -eq 0) {
		${GOOGLEAI_BLOCK_DANGEROUS_CONTENT} = "BLOCK_NONE"
	}

	if ($(STRINGS-Is-Empty "${env:GOOGLEAI_BLOCK_HARASSMENT}") -eq 0) {
		${env:GOOGLEAI_BLOCK_HARASSMENT} = "BLOCK_NONE"
	}

	$___url = "${env:GOOGLEAI_API_URL}/${env:GOOGLEAI_API_VERSION}/${env:GOOGLEAI_MODEL}"
	$___url = "${___url}:generateContent?key=${env:GOOGLEAI_API_TOKEN}"


	# execute
	return "$(curl.exe --no-progress-meter --header 'Content-Type: application/json' --data @"
{
	"contents" = [{
		"parts": [{
			"text": "${___query}"
		}],
		"role": "user"
	}],
	"safetySettings": [{
		"category": "HARM_CATEGORY_HATE_SPEECH",
		"threshold": "${env:GOOGLEAI_BLOCK_HATE_SPEECH}"
	}, {
		"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
		"threshold": "${env:GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT}"
	}, {
		"category": "HARM_CATEGORY_DANGEROUS_CONTENT",
		"threshold": "${env:GOOGLEAI_BLOCK_DANGEROUS_CONTENT}"
	}, {
		"category": "HARM_CATEGORY_HARASSMENT",
		"threshold": "${env:GOOGLEAI_BLOCK_HARASSMENT}"
	}]
}
"@ `
	--request POST "$___url")"
}




function GOOGLEAI-Is-Available {
	$___process = OS-Is-Command-Available "curl"
	if ($___process -ne 0) {
		return 1
	}

	if (($(STRINGS-Is-Empty "${env:GOOGLEAI_API_URL}") -eq 0) -and
		($(STRINGS-Is-Empty "${env:GOOGLEAI_API_VERSION}") -eq 0) -and
		($(STRINGS-Is-Empty "${env:GOOGLEAI_MODEL}") -eq 0) -and
		($(STRINGS-Is-Empty "${env:GOOGLEAI_API_TOKEN}") -eq 0)) {
		return 1
	}

	# report status
	return 0
}




# execute command
$__query = ""
$__config_path = ""
$__mode = ""


## parse parameters
for ($i = 0; $i -lt $args.Length; $i++) {
	switch ($args[$i]) {
	{ $_ -in "-h", "--help", "help" } {
		$null = Print-Status "note" @"

╔═══════════════╗
║Holloway's HiAI║
╚═══════════════╝
Quick Start:
  (1) $ hiAI --create-config './CONFIG.toml'

  (2) # edit the CONFIG.toml and fill in all the settings including API token.

  (3) $ hiAI --config './CONFIG.toml' --text2text '...your prompt here...'
  ...


┌──────┐
│Params│
└──────┘
--help                          bring up this self-help panel.
--create-config [FILEPATH]      create the TOML config file at [FILEPATH]. If
                                the destination exists, this function will fail
                                as error.
--config [FILEPATH]             loads the TOML config file from [FILEPATH] for
                                operation. If the source is missing, this
                                function will fail.
--text2text [STRING]            operate text-to-text prompt.
`n
"@
		exit 0
	} "--create-config" {
		$___destination = ""
		if (-not ($args[$i + 1] -match "^--")) {
			$___destination = $args[$i + 1]
			$i++
		}

		$___process = FS-Is-File "${___destination}"
		if ($___process -eq 0) {
			$null = Print-Status error "${___destination} exists!`n"
			exit 1
		}

		$___process = FS-Is-Directory "${___destination}"
		if ($___process -eq 0) {
			$null = Print-Status error "${___destination} exists!`n"
			exit 1
		}

		$___process = FS-Make-Housing-Directory "${___destination}"
		if ($___process -ne 0) {
			$null = Print-Status error "failed to make housing directory!`n"
			exit 1
		}

		$___process = FS-Write-File "${___destination}" @"
######################
# GENERAL            #
######################
# AI_VENDOR
# This is to select vendor. Supported vendors are:
#   (1) Google AI = 'GOOGLEAI'
AI_VENDOR = 'GOOGLEAI'




######################
# GOOGLE AI          #
######################
# GOOGLEAI_API_TOKEN
# This is the authentication API token provided by Google AI using Google AI
# Studio. A token can be purchased from:
#     (1) https://aistudio.google.com/ (look for 'Get API Key' button)
#
# Without this token, GOOGLEAI library will not function at all.
GOOGLEAI_API_TOKEN = ''


# GOOGLEAI_API_URL
# This is the base URL for Google AI API interfaces. It is specified in
#     (1) https://ai.google.dev/api/rest
#     (2) https://ai.google.dev/tutorials/rest_quickstart
#
# This is used to enable Google AI interfacing for terminal. Note that without
# the GOOGLE_AI_API_TOKEN (in SECRETS.toml), Google AI cloud services are
# unavailable.
GOOGLEAI_API_URL = 'https://generativelanguage.googleapis.com'


# GOOGLEAI_API_VERSION
# This specifies the API interface version. It is specified in
#     (1) https://ai.google.dev/api/rest
#
# This is used to configure Google AI API interfaces for terminal.
GOOGLEAI_API_VERSION = 'v1beta'


# GOOGLEAI_MODEL
# This specifies the AI model to be used. It is specified in:
#     (1) https://ai.google.dev/models/
#
# This is used to configure Google AI API interfaces for terminal and it's part
# of its url. Hence, the correct value is usually leads with 'models/[TYPE]'.
#
# Default is: models/gemini-pro
GOOGLEAI_MODEL = 'models/gemini-pro'


# GOOGLEAI_BLOCK_HATE_SPEECH
# This specifies the AI filtering category for hate speeches. It uses the
# string-type enumerated values stated in:
#     (1) https://ai.google.dev/api/rest/v1beta/HarmCategory
#     (2) https://ai.google.dev/api/rest/v1beta/SafetySetting#HarmBlockThreshold
#
# Acceptable values are:
#     (1) 'HARM_BLOCK_THRESHOLD_UNSPECIFIED' - not specified
#     (2) 'BLOCK_LOW_AND_ABOVE' - NEGLIGIBLE is allowed.
#     (3) 'BLOCK_MEDIUM_AND_ABOVE' - LOW & NEGLIGIBLE allowed.
#     (4) 'BLOCK_ONLY_HIGH' - MEDIUM, LOW & NEGLIGIBLE allowed.
#     (5) 'BLOCK_NONE' - All content will be allowed.
#
# If value is unavailable (empty string), then 'BLOCK_NONE' is the default.
GOOGLEAI_BLOCK_HATE_SPEECH = 'BLOCK_NONE'


# GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT
# This specifies the AI filtering category for sexually explicit content. It
# uses the string-type enumerated values stated in:
#     (1) https://ai.google.dev/api/rest/v1beta/HarmCategory
#     (2) https://ai.google.dev/api/rest/v1beta/SafetySetting#HarmBlockThreshold
#
# Acceptable values are:
#     (1) 'HARM_BLOCK_THRESHOLD_UNSPECIFIED' - not specified
#     (2) 'BLOCK_LOW_AND_ABOVE' - NEGLIGIBLE is allowed.
#     (3) 'BLOCK_MEDIUM_AND_ABOVE' - LOW & NEGLIGIBLE allowed.
#     (4) 'BLOCK_ONLY_HIGH' - MEDIUM, LOW & NEGLIGIBLE allowed.
#     (5) 'BLOCK_NONE' - All content will be allowed.
#
# If value is unavailable (empty string), then 'BLOCK_NONE' is the default.
GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT = 'BLOCK_NONE'


# GOOGLEAI_BLOCK_DANGEROUS_CONTENT
# This specifies the AI filtering category for dangerous content. It
# uses the string-type enumerated values stated in:
#     (1) https://ai.google.dev/api/rest/v1beta/HarmCategory
#     (2) https://ai.google.dev/api/rest/v1beta/SafetySetting#HarmBlockThreshold
#
# Acceptable values are:
#     (1) 'HARM_BLOCK_THRESHOLD_UNSPECIFIED' - not specified
#     (2) 'BLOCK_LOW_AND_ABOVE' - NEGLIGIBLE is allowed.
#     (3) 'BLOCK_MEDIUM_AND_ABOVE' - LOW & NEGLIGIBLE allowed.
#     (4) 'BLOCK_ONLY_HIGH' - MEDIUM, LOW & NEGLIGIBLE allowed.
#     (5) 'BLOCK_NONE' - All content will be allowed.
#
# If value is unavailable (empty string), then 'BLOCK_NONE' is the default.
GOOGLEAI_BLOCK_DANGEROUS_CONTENT = 'BLOCK_NONE'


# GOOGLEAI_BLOCK_HARASSMENT
# This specifies the AI filtering category for harassment content. It
# uses the string-type enumerated values stated in:
#     (1) https://ai.google.dev/api/rest/v1beta/HarmCategory
#     (2) https://ai.google.dev/api/rest/v1beta/SafetySetting#HarmBlockThreshold
#
# Acceptable values are:
#     (1) 'HARM_BLOCK_THRESHOLD_UNSPECIFIED' - not specified
#     (2) 'BLOCK_LOW_AND_ABOVE' - NEGLIGIBLE is allowed.
#     (3) 'BLOCK_MEDIUM_AND_ABOVE' - LOW & NEGLIGIBLE allowed.
#     (4) 'BLOCK_ONLY_HIGH' - MEDIUM, LOW & NEGLIGIBLE allowed.
#     (5) 'BLOCK_NONE' - All content will be allowed.
#
# If value is unavailable (empty string), then 'BLOCK_NONE' is the default.
GOOGLEAI_BLOCK_HARASSMENT = 'BLOCK_NONE'
"@
		exit 0
	} "--config" {
		if (-not ($args[$i + 1] -match "^--")) {
			$__config_path = $args[$i + 1]
			$i++
		}
	} "--text2text" {
		$__mode = "t2t"
		if (-not ($args[$i + 1] -match "^--")) {
			$__query = $args[$i + 1]
			$i++
		}
	} default {
	}}
}


## check run mode
if ($(STRINGS-Is-Empty "${__mode}") -eq 0) {
	$null = Print-Status "error" "No action given. Please run --help for assistances.`n"
	exit 1
}


## parse configurations file
$___process = FS-Is-File "${__config_path}"
if ($___process -ne 0) {
	$null = Print-Status "error" "missing required CONFIG.toml file."
	exit 1
}

foreach ($__line in (Get-Content "${__config_path}")) {
	$__line = $__line -replace '#.*', ''

	$__process = STRINGS-Is-Empty "${__line}"
	if ($__process -eq 0) {
		continue
	}

	$__key, $__value = $__line -split '=', 2
	$__key = $__key.Trim() -replace '^''|''$|^"|"$'
	$__value = $__value.Trim() -replace '^''|''$|^"|"$'

	$null = Set-Item -Path "env:$__key" -Value $__value
}


## communicate with AI
switch ("${env:AI_VENDOR}") {
"GOOGLEAI" {
	if ("${__mode}" -eq "t2i") {
		## text-to-image
		$null = Print-Status "info" "text-to-image mode coming soon.`n"
		exit 1
	}

	## text-to-text
	$null = Print-Status "info" "contacting Google Gemini..."
	$___response = GOOGLEAI-Gemini-Query-Text-To-Text "${__query}"

	### parse json response if available
	if ($(STRINGS-Is-Empty "${___response}") -ne 0) {
		$___response = "$($___response `
				| ConvertFrom-Json `
				| Select-Object `
					-ErrorAction SilentlyContinue `
					-ExpandProperty candidates[0].content.parts[0].text
		)"
	}
	$null = Write-Host "${___response}"
} default {
	$null = Print-Status "error" "Unknown AI vendor.`n"
	exit 1
}}




# report status
$null = Print-Status "plain" "`n"
$null = Print-Status "success"
exit 0
