#!/bin/sh
# Copyright 2023 (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at:
#                http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.




# initialize
if [ "$PROJECT_PATH_ROOT" = "" ]; then
        >&2 printf "[ ERROR ] - Please run from automataCI/ci.sh.ps1 instead!\n"
        return 1
fi

. "${LIBS_AUTOMATACI}/services/io/fs.sh"
. "${LIBS_AUTOMATACI}/services/i18n/translations.sh"
. "${LIBS_AUTOMATACI}/services/compilers/changelog.sh"




# execute
I18N_Check_Availability 'CHANGELOG'
CHANGELOG_Is_Available
if [ $? -ne 0 ]; then
        I18N_Check_Failed
        return 1
fi




# assemble polygot script
___workspace="${PROJECT_PATH_ROOT}/${PROJECT_PATH_TEMP}/build-${PROJECT_SKU}"
FS_Remake_Directory "$___workspace"


___dest="${___workspace}/${PROJECT_SKU}.sh.ps1"
I18N_Create "$___dest"
FS_Write_File "$___dest" "\
echo \\\" <<'RUN_AS_BATCH' >/dev/null \">NUL \"\\\" \\\`\" <#\"
@ECHO OFF
REM LICENSE CLAUSES HERE
REM ----------------------------------------------------------------------------




REM ############################################################################
REM # Windows BATCH Codes                                                      #
REM ############################################################################
where /q powershell
if errorlevel 1 (
        echo \"ERROR: missing powershell facility.\"
        exit /b 1
)

copy /Y \"%~nx0\" \"%~n0.ps1\" >nul
timeout /t 1 /nobreak >nul
powershell -executionpolicy remotesigned -Command \"& '.\\%~n0.ps1' %*\"
start /b \"\" cmd /c del \"%~f0\" & exit /b %errorcode%
REM ############################################################################
REM # Windows BATCH Codes                                                      #
REM ############################################################################
RUN_AS_BATCH
#> | Out-Null




echo \\\" <<'RUN_AS_POWERSHELL' >/dev/null # \" | Out-Null
################################################################################
# Windows POWERSHELL Codes                                                     #
################################################################################
"
if [ $? -ne 0 ]; then
        I18N_Create_Failed
        return 1
fi

## append src/main.ps1
___old_IFS="$IFS"
while IFS= read -r __line || [ -n "$__line" ]; do
        if [ "$(STRINGS_Is_Empty "$__line")" -eq 0 ]; then
                continue
        fi

        printf -- "%s\n" "$__line" >> "$___dest"
done < "${PROJECT_PATH_ROOT}/${PROJECT_PATH_SOURCE}/main.ps1"

## to posix shell header
FS_Append_File "$___dest" "\
################################################################################
# Windows POWERSHELL Codes                                                     #
################################################################################
exit
<#
RUN_AS_POWERSHELL




################################################################################
# Unix Main Codes                                                              #
################################################################################
"
if [ $? -ne 0 ]; then
        I18N_Create_Failed
        return 1
fi

## append src/main.sh
___old_IFS="$IFS"
while IFS= read -r __line || [ -n "$__line" ]; do
        if [ "$(STRINGS_Is_Empty "$__line")" -eq 0 ]; then
                continue
        fi

        printf -- "%s\n" "$__line" >> "$___dest"
done < "${PROJECT_PATH_ROOT}/${PROJECT_PATH_SOURCE}/main.sh"
IFS="$___old_IFS" && unset __old_IFS

## close
FS_Append_File "$___dest" "\
################################################################################
# Unix Main Codes                                                              #
################################################################################
exit \$?
#>
"
if [ $? -ne 0 ]; then
        I18N_Create_Failed
        return 1
fi

FS_Is_File "$___dest"
if [ $? -ne 0 ]; then
        I18N_Create_Failed
        return 1
fi
chmod +x "$___dest"

## test
___source="$___dest"
I18N_Test "$___source --help"

eval "${___source} --help"
if [ $? -ne 0 ]; then
        I18N_Test_Failed
        return 1
fi

___config="${___workspace}/CONFIG.toml"
I18N_Test "$___source --create-config ${___config}"
eval "${___source} --create-config '${___config}'"
if [ $? -ne 0 ]; then
        I18N_Test_Failed
        return 1
fi

FS_Is_File "$___config"
if [ $? -ne 0 ]; then
        I18N_Test_Failed
        return 1
fi


I18N_Test "$___source --text2text"
I18N_Newline
I18N_Newline
GOOGLE_API_TOKEN="${GOOGLE_API_TOKEN:-"Some_Dummy_Value"}"
eval "${___source} --config '${___config}' --text2text 'What are you?'"
if [ $? -ne 0 ]; then
        I18N_Test_Failed
        return 1
fi
I18N_Newline
I18N_Newline




# export
FS_Make_Directory "${PROJECT_PATH_ROOT}/${PROJECT_PATH_BUILD}"

__old_IFS="$IFS"
while IFS= read -r __line || [ -n "$__line" ]; do
        ___dest="${PROJECT_PATH_ROOT}/${PROJECT_PATH_BUILD}/${PROJECT_SKU}_${__line}.sh.ps1"
        I18N_Export "$___dest"
        FS_Copy_File "$___source" "$___dest"
        if [ $? -ne 0 ]; then
                I18N_Export_Failed
                return 1
        fi
done <<EOF
darwin-amd64
darwin-arm64
linux-386
linux-amd64
linux-arm64
linux-arm
linux-loong64
linux-mips
linux-mips64
linux-mips64le
linux-ppc64
linux-ppc64le
linux-riscv64
linux-s390x
windows-amd64
windows-arm64
EOF
IFS="$__old_IFS" && unset __old_IFS




# build changelog entries
__file="${PROJECT_PATH_ROOT}/${PROJECT_PATH_SOURCE}/changelog"
I18N_Create "${PROJECT_VERSION} DATA CHANGELOG"
CHANGELOG_Build_Data_Entry "$__file"
if [ $? -ne 0 ]; then
        I18N_Create_Failed
        return 1
fi


I18N_Create "${PROJECT_VERSION} DEB CHANGELOG"
CHANGELOG_Build_DEB_Entry \
        "$__file" \
        "$PROJECT_VERSION" \
        "$PROJECT_SKU" \
        "$PROJECT_DEBIAN_DISTRIBUTION" \
        "$PROJECT_DEBIAN_URGENCY" \
        "$PROJECT_CONTACT_NAME" \
        "$PROJECT_CONTACT_EMAIL" \
        "$(date -R)"
if [ $? -ne 0 ]; then
        I18N_Create_Failed
        return 1
fi




# report status
return 0
