#!/bin/sh
# Copyright 2023  (Holloway) Chew, Kean Ho <hollowaykeanho@gmail.com>
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
. "${LIBS_AUTOMATACI}/services/io/os.sh"
. "${LIBS_AUTOMATACI}/services/io/fs.sh"
. "${LIBS_AUTOMATACI}/services/io/strings.sh"




GZ_Create() {
        ___source="$1"


        # validate input
        GZ_Is_Available
        if [ $? -ne 0 ]; then
                return 1
        fi

        if [ $(STRINGS_Is_Empty "$___source") -eq 0 ]; then
                return 1
        fi

        FS_Is_Directory "$___source"
        if [ $? -eq 0 ]; then
                return 1
        fi


        # create .gz compressed target
        ___source="${___source%.gz}"

        OS_Is_Command_Available "gzip"
        if [ $? -eq 0 ]; then
                gzip -9 "$___source"
                if [ $? -ne 0 ]; then
                        return 1
                fi

                return 0
        fi

        OS_Is_Command_Available "gunzip"
        if [ $? -eq 0 ]; then
                gunzip -9 "$___source"
                if [ $? -ne 0 ]; then
                        return 1
                fi

                return 0
        fi


        # report status
        return 1
}




GZ_Is_Available() {
        # execute
        OS_Is_Command_Available "gzip"
        if [ $? -eq 0 ]; then
                return 0
        fi

        OS_Is_Command_Available "gunzip"
        if [ $? -eq 0 ]; then
                return 0
        fi


        # report status
        return 1
}
