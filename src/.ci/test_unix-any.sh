#!/bin/sh
# Copyright 2024 (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
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

. "${LIBS_AUTOMATACI}/services/io/os.sh"
. "${LIBS_AUTOMATACI}/services/io/fs.sh"
. "${LIBS_AUTOMATACI}/services/io/net/http.sh"
. "${LIBS_AUTOMATACI}/services/i18n/translations.sh"




# execute
I18N_Activate_Environment
OS_Is_Command_Available "curl"
if [ $? -ne 0 ]; then
        I18N_Activate_Failed
        return 1
fi


___source="${PROJECT_PATH_ROOT}/${PROJECT_PATH_SOURCE}/main.sh"
___workspace="${PROJECT_PATH_ROOT}/${PROJECT_PATH_TEMP}/test_hiAI"
FS_Remake_Directory "$___workspace"


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
GOOGLE_API_TOKEN="${GOOGLE_API_TOKEN:-"Some_Dummy_Value"}"
eval "${___source} --config '${___config}' --text2text 'What are you?'"
if [ $? -ne 0 ]; then
        I18N_Test_Failed
        return 1
fi




# report status
return 0
