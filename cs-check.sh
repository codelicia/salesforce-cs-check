#!/bin/bash

shopt -s -o nounset

declare -x EXIT_CODE=0
declare -x FILES_QUANTITY=0

# Statistics
declare -xi QUANTITY_OF_FILES=0
declare -xi QUANTITY_OF_FAILUES=0
declare -xi QUANTITY_OF_OK=0
declare -x  ERRORS_LIST=""

printf "\nApex codestandards by Codelicia\n\n"

for file in force-app/main/default/classes/*.cls; do
    declare -x ERROR_METADATA=false
    declare -x ERROR_TEST_NAME=false
    declare -x ERROR_IS_TEST_ANNOTATION=false
    declare -x ERROR_TABS=false
    declare -x ERROR_TRAILING_SPACE=false

    declare -x TEMP_ERRORS=""

    let QUANTITY_OF_FILES++

    # All files has metadata
    if [[ ! -f "$file-meta.xml" ]]; then
        ERROR_METADATA=true
        TEMP_ERRORS="$TEMP_ERRORS  - We didn't find a metadata clas\n"
    fi

    # Check for name convention for Test classes
    if [[ "$file" == *"Test"* ]]; then
        if [[ "$file" != *"Test.cls"* ]]; then
            ERROR_TEST_NAME=true
            TEMP_ERRORS="$TEMP_ERRORS  - You should name your tests classes as *Test.cls\n"
        fi
    fi

    # Check for trailing spaces
    declare -x HAS_TRAILING_SPACES=$(sed -n '/ \+$/p' "$file" | wc -l)
    if [[ "$HAS_TRAILING_SPACES" -gt "0" ]]; then
            ERROR_TRAILING_SPACE=true
            TEMP_ERRORS="$TEMP_ERRORS  - Remove triailing spaces from Apex code\n"
    fi

    # Check for "@IsTest" usage enforcing common notation
    declare -x IS_TEST=$(cat "$file" | grep -y 'istest' | wc -l)
    if [[ "$IS_TEST" -gt "0" ]]; then
        cat "$file" | grep -y 'istest' | while read -r match; do
            if [[ "$match" != *"IsTest"* ]]; then
                ERROR_IS_TEST_ANNOTATION=true
                TEMP_ERRORS="$TEMP_ERRORS  - You should use @IsTest annotation (case sensitive)\n"
                continue
            fi
        done
    fi

    # Check if files are using "tabs", we should use only spaces to ident files
    declare -x COUNT_OF_TABS_IN_LINES=$(cat "$file" | grep -P "\t" | wc -l)
    if [[ "$COUNT_OF_TABS_IN_LINES" -gt "0" ]]; then
        ERROR_TABS=true
        TEMP_ERRORS="$TEMP_ERRORS  - Only spaces are allowed for indentation\n"
    fi

    # Handle dotted output and store error information
    if [[ ${ERROR_TABS} = true || ${ERROR_IS_TEST_ANNOTATION} = true || ${ERROR_TEST_NAME} = true || ${ERROR_METADATA} = true || ${ERROR_TRAILING_SPACE} = true ]]; then
        echo -n 'F'
        let QUANTITY_OF_FAILUES++
        EXIT_CODE=1
        ERRORS_LIST="$ERRORS_LIST\n$file\n$TEMP_ERRORS"
    else
        echo -n '.'
        let QUANTITY_OF_OK++
    fi

done

if [[ "$QUANTITY_OF_FAILUES" -gt "0" ]];
then
    printf "\n\nThere was %d failure:\n" "$QUANTITY_OF_FAILUES"
    printf "$ERRORS_LIST"
    printf "\n\nFAILURE!\nFiles: %d, OK: %d, Failures: %d.\n" "$QUANTITY_OF_FILES" "$QUANTITY_OF_OK" "$QUANTITY_OF_FAILUES"
else
    printf "\n\nOK (files %d, ok %d)\n" "$QUANTITY_OF_FILES" "$QUANTITY_OF_OK"
fi

exit ${EXIT_CODE}
