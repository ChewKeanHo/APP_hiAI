#!/bin/sh
# Copyright 2024 (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at:
#                 http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
Status_Tag_Create() {
        #___content="$1"
        #___spacing="$2"


        # validate input
        if [ "$(STRINGS_Is_Empty "$1")" -eq 0 ]; then
                printf -- ""
                return 0
        fi


        # execute
        printf -- "%b" "⦗$1⦘$2"
        return 0
}




Status_Tag_Get_Type() {
        #___mode="$1"


        # execute (REMEMBER: make sure the text and spacing are having the same length)
        case "$1" in
        error)
                printf -- "%b" "$(Status_Tag_Create " ERROR " "   ")"
                ;;
        warning)
                printf -- "%b" "$(Status_Tag_Create " WARNING " " ")"
                ;;
        info)
                printf -- "%b" "$(Status_Tag_Create " INFO " "    ")"
                ;;
        note)
                printf -- "%b" "$(Status_Tag_Create " NOTE " "    ")"
                ;;
        success)
                printf -- "%b" "$(Status_Tag_Create " SUCCESS " " ")"
                ;;
        ok)
                printf -- "%b" "$(Status_Tag_Create " OK " "      ")"
                ;;
        done)
                printf -- "%b" "$(Status_Tag_Create " DONE " "    ")"
                ;;
        *)
                printf -- ""
                ;;
        esac
}




Print_Status() {
        #___mode="$1"
        #___message="$2"


        # execute
        ___tag="$(Status_Tag_Get_Type "$1")"
        ___color=""
        case "$1" in
        error)
                ___color="31"
                ;;
        warning)
                ___color="33"
                ;;
        info)
                ___color="36"
                ;;
        note)
                ___color="35"
                ;;
        success)
                ___color="32"
                ;;
        ok)
                ___color="36"
                ;;
        done)
                ___color="36"
                ;;
        *)
                # do nothing
                ;;
        esac

        if [ ! -z "$COLORTERM" ] || [ "$TERM" = "xterm-256color" ]; then
                # terminal supports color mode
                if [ ! -z "$___color" ]; then
                        1>&2 printf -- "%b" \
                                "\033[1;${___color}m${___tag}\033[0;${___color}m${2}\033[0m"
                else
                        1>&2 printf -- "%b" "${___tag}${2}"
                fi
        else
                1>&2 printf -- "%b" "${___tag}${2}"
        fi

        unset ___color ___tag
}




OS_Is_Command_Available() {
        #___command="$1"


        # validate input
        if [ -z "$1" ]; then
                return 1
        fi


        # execute
        2>/dev/null 1>/dev/null type "$1"
        if [ $? -eq 0 ]; then
                return 0
        fi


        # report status
        return 1
}




FS_Is_Directory() {
        #___target="$1"


        # validate input
        if [ -z "$1" ]; then
                return 1
        fi


        # execute
        if [ -d "$1" ]; then
                return 0
        fi


        # report status
        return 1
}




FS_Is_File() {
        #___target="$1"


        # validate input
        if [ -z "$1" ]; then
                return 1
        fi


        # execute
        FS_Is_Directory "$1"
        if [ $? -eq 0 ]; then
                return 1
        fi

        if [ -f "$1" ]; then
                return 0
        fi


        # report status
        return 1
}




FS_Make_Housing_Directory() {
        #___target="$1"


        # validate input
        if [ -z "$1" ]; then
                return 1
        fi

        FS_Is_Directory "$1"
        if [ $? -eq 0 ]; then
                return 0
        fi


        # perform create
        mkdir -p "${1%/*}"


        # report status
        return $?
}




FS_Write_File() {
        #___target="$1"
        #___content="$2"


        # validate input
        if [ -z "$1" ]; then
                return 1
        fi

        FS_Is_File "$1"
        if [ $? -eq 0 ]; then
                return 1
        fi


        # perform file write
        printf -- "%b" "$2" >> "$1"
        if [ $? -eq 0 ]; then
                return 0
        fi


        # report status
        return 1
}




STRINGS_Is_Empty() {
        #___target="$1"


        # execute
        if [ -z "$1" ]; then
                printf -- "0"
                return 0
        fi


        # report status
        printf -- "1"
        return 1
}




GOOGLEAI_Gemini_Query_Text_To_Text() {
        #___query="$1"


        # validate input
        if [ $(STRINGS_Is_Empty "$1") -eq 0 ]; then
                return 1
        fi

        GOOGLEAI_Is_Available
        if [ $? -ne 0 ]; then
                return 1
        fi


        # configure
        if [ $(STRINGS_Is_Empty "$GOOGLEAI_BLOCK_HATE_SPEECH") -eq 0 ]; then
                GOOGLEAI_BLOCK_HATE_SPEECH="BLOCK_NONE"
        fi

        if [ $(STRINGS_Is_Empty "$GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT") -eq 0 ]; then
                GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT="BLOCK_NONE"
        fi

        if [ $(STRINGS_Is_Empty "$GOOGLEAI_BLOCK_DANGEROUS_CONTENT") -eq 0 ]; then
                GOOGLEAI_BLOCK_DANGEROUS_CONTENT="BLOCK_NONE"
        fi

        if [ $(STRINGS_Is_Empty "$GOOGLEAI_BLOCK_HARASSMENT") -eq 0 ]; then
                GOOGLEAI_BLOCK_HARASSMENT="BLOCK_NONE"
        fi

        ___url="${GOOGLEAI_API_URL}/${GOOGLEAI_API_VERSION}/${GOOGLEAI_MODEL}"
        ___url="${___url}:generateContent?key=${GOOGLEAI_API_TOKEN}"


        # execute
        curl --no-progress-meter --header 'Content-Type: application/json' --data "{
        \"contents\": [{
                \"parts\":[{
                        \"text\": \"${1}\"
                }],
                \"role\": \"user\"
        }],
        \"safetySettings\": [{
                \"category\": \"HARM_CATEGORY_HATE_SPEECH\",
                \"threshold\": \"${GOOGLEAI_BLOCK_HATE_SPEECH}\"
        },  {
                \"category\": \"HARM_CATEGORY_SEXUALLY_EXPLICIT\",
                \"threshold\": \"${GOOGLEAI_BLOCK_SEXUALLY_EXPLICIT}\"
        },  {
                \"category\": \"HARM_CATEGORY_DANGEROUS_CONTENT\",
                \"threshold\": \"${GOOGLEAI_BLOCK_DANGEROUS_CONTENT}\"
        },  {
                \"category\": \"HARM_CATEGORY_HARASSMENT\",
                \"threshold\": \"${GOOGLEAI_BLOCK_HARASSMENT}\"
        }]
}" --request POST "$___url"
        if [ $? -ne 0 ]; then
                return 1
        fi


        # report status
        return 0
}




GOOGLEAI_Is_Available() {
        # execute
        OS_Is_Command_Available "curl"
        if [ $? -ne 0 ]; then
                return 1
        fi

        if [ $(STRINGS_Is_Empty "$GOOGLEAI_API_URL") -eq 0 ] &&
                [ $(STRINGS_Is_Empty "$GOOGLEAI_API_VERSION") -eq 0 ] &&
                [ $(STRINGS_Is_Empty "$GOOGLEAI_MODEL") -eq 0 ] &&
                [ $(STRINGS_Is_Empty "$GOOGLEAI_API_TOKEN") -eq 0 ]; then
                return 1
        fi


        # report status
        return 0
}




# execute command
__query=""
__config_path=""
__mode=""


## parse parameters
while [ -n "$1" ]; do
        case "$1" in
        -h|--help|help)
                Print_Status note "
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
"
                exit 0
                ;;
        --create-config)
                if [ ! -z "$2" ] && [ "$(printf "%.1s" "$2")" != "-" ]; then
                        ___destination="$2"
                        shift 1
                fi

                FS_Is_File "$___destination"
                if [ $? -eq 0 ]; then
                        Print_Status error "${___destination} exists!\n"
                        exit 1
                fi

                FS_Is_Directory "$___destination"
                if [ $? -eq 0 ]; then
                        Print_Status error "${___destination} exists!\n"
                        exit 1
                fi

                FS_Make_Housing_Directory "$___destination"
                if [ $? -ne 0 ]; then
                        Print_Status error "failed to create housing directory.\n"
                        exit 1
                fi


                FS_Write_File "$___destination" "\
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
"
                exit 0
                ;;
        --config)
                if [ ! -z "$2" ] && [ "$(printf "%.1s" "$2")" != "-" ]; then
                        __config_path="$2"
                        shift 1
                fi
                ;;
        --text2text)
                __mode="t2t"
                if [ ! -z "$2" ] && [ "$(printf "%.1s" "$2")" != "-" ]; then
                        __query="$2"
                        shift 1
                fi
                ;;
        esac
        shift 1
done


## check run mode
if [ $(STRINGS_Is_Empty "$__mode") -eq 0 ]; then
        Print_Status error "No action given. Please run --help for assistances.\n"
        exit 1
fi


## parse configurations file
FS_Is_File "$__config_path"
if [ $? -ne 0 ]; then
        Print_Status error "missing required CONFIG.toml file.\n"
        exit 1
fi

__old_IFS="$IFS"
while IFS= read -r __line || [ -n "$__line" ]; do
        __line="${__line%%#*}"
        if [ "$(STRINGS_Is_Empty "$__line")" -eq 0 ]; then
                continue
        fi

        key="${__line%%=*}"
        key="${key#"${key%%[![:space:]]*}"}"
        key="${key%"${key##*[![:space:]]}"}"
        key="${key%\"}"
        key="${key#\"}"
        key="${key%\'}"
        key="${key#\'}"

        value="${__line##*=}"
        value="${value#"${value%%[![:space:]]*}"}"
        value="${value%"${value##*[![:space:]]}"}"
        value="${value%\"}"
        value="${value#\"}"
        value="${value%\'}"
        value="${value#\'}"

        export "$key"="$value"
done < "$__config_path"
IFS="$__old_IFS" && unset __old_IFS


## communicate with AI
case "$AI_VENDOR" in
GOOGLEAI)
        if [ "$__mode" = "t2i" ]; then
                ## text-to-image
                Print_Status info "text-to-image mode coming soon.\n"
                exit 1
        fi

        ## text-to-text
        Print_Status info "contacting Google Gemini...\n"
        ___response="$(GOOGLEAI_Gemini_Query_Text_To_Text "$__query")"
        if [ $? -ne 0 ]; then
                Print_Status error "connection failed.\n"
                exit 1
        fi

        ### parse json response if available
        if [ $(STRINGS_Is_Empty "$___response") -ne 0 ]; then
                OS_Is_Command_Available "jq"
                if [ $? -eq 0 ]; then
                        ___response="$(printf -- "%s" "$___response" \
                                | jq --raw-output .candidates[0].content.parts[0].text)"
                fi
        fi
        printf -- "%b" "$___response"
        ;;
*)
        Print_Status error "Unknown AI vendor.\n"
        exit 1
        ;;
esac




# report status
Print_Status plain "\n"
Print_Status success "\n"
exit 0
