#!/bin/bash
#
# Copyright (c) 2020 Synopsys, Inc. All rights reserved worldwide. The information
# contained in this file is the proprietary and confidential information of
# Synopsys, Inc. and its licensors, and is supplied subject to, and may be used
# only by Synopsys customers in accordance with the terms and conditions of a
# previously executed license agreement between Synopsys and that customer.
#
# Author: M. Zaid Alam
#
# Version: 2020.06.19
#
# FUNCTION:
# The script is intended to export a bom along with any changes made to it
#
# ALGORITIHM:
# - Authenticate
# - Find the given project by name
# - Find the given version in the project
# - Get the signature scans attached to a project version
# - Process match counts
# - if snippet is enabled also count unique files confirmed by snippets
#
# Usage:
# ./get_match_coverage.sh -u <blackduck url> -a <api token> -p <project name> -v <version> --consider-snippets <true|false>
#
#
# Example:
# ./get_match_coverage.sh -u https://myblackduck -a top-secret-api-token -p example-project -v 1 --consider-snippets true


# Globals for input
ACCESS_TOKEN=""
WEB_URL=""
PROJECT_NAME=""
VERSION_NAME=""
CONSIDER_SNIPPETS=false
USER_NAME="sysadmin"
USER_PASSWORD="blackduck"

# As long as there is at least one more argument, keep looping
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        # Project name to find
        -p|--project-name)
            shift
            PROJECT_NAME="$1"
        ;;
        # Access token arg passed as space
        -a|--access-token)
            shift
            ACCESS_TOKEN="$1"
        ;;
        # HUB url arg passed as space
        -u|--hub-url)
            shift
            WEB_URL="$1"
        ;;
        # Project version name to find
        -v|--project-version)
            shift
            VERSION_NAME="$1"
        ;;
        # Consider snippets?
        --consider-snippets)
            shift
            CONSIDER_SNIPPETS="$1"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done

# Function to validate inputs
function validate_inputs()
{
    # Check all required inputs are provided
    if [[ -z "${ACCESS_TOKEN}"  || -z "${WEB_URL}" || -z "${PROJECT_NAME}" || -z "${VERSION_NAME}" ]]
    #if [[ -z "${WEB_URL}" || -z "${PROJECT_NAME}" || -z "${VERSION_NAME}" ]]
    then
        echo "Script inputs missing please see the following example:"
        echo "./$(basename $BASH_SOURCE) -p <project name> -v <version name> -u <blackduck_url> -a <api_token>"
        #echo "./$(basename $BASH_SOURCE) -p <project name> -v <version name> -u <blackduck_url>"
        exit 1
    else
        echo "Inputs validated..."
    fi
}

# validate script requirements
function validate_requirements()
{
    # Check if jq and curl are installed
    local jq=$(command -v jq)
    local curl=$(command -v curl)

    if [[ -z "${jq}" || -z "${curl}" ]]
    then
        echo "jq and curl are required for this script"
        echo "aborting..."
        exit 1
    else
        echo "Tool requirements verified"
    fi
}

# Authenticate
function authenticate()
{
    local response=$(curl -s --insecure -X POST --header "Content-Type:application/json" --header "Authorization: token $ACCESS_TOKEN" "$WEB_URL/api/tokens/authenticate")
    # curl - --user admin:password
    #local response=$(curl -s --insecure --user "${USER_NAME}:${USER_PASSWORD}" -X POST --header "Content-Type:application/json" "$WEB_URL/api/tokens/authenticate")
    #local response=$(curl -s --insecure --username="${USER_NAME}" --password="${USER_PASSWORD}" -X POST --header "Content-Type:application/json" "$WEB_URL/api/tokens/authenticate")
    bearer_token=$(echo "${response}" | jq --raw-output '.bearerToken')
    if [ -z ${bearer_token} ]
    then
        echo "Could not authenticate, aborting..."
        exit 1
    else
        echo "Authenticated successfully..."
    fi
}

# Find project by name
function get_project()
{
    local response=$(curl -s --insecure -X GET --header "Content-Type:application/json" --header "Authorization: bearer $bearer_token" "$WEB_URL/api/projects?q=name:$PROJECT_NAME")
    response=$(echo "${response}" | jq --raw-output '.items[] | select(.name=='\""$PROJECT_NAME"\"')')
    if [ -z "${response}" ]
    then
        echo "Could not find a project with name: $PROJECT_NAME ...aborting"
        exit 1
    else
        echo "Found project: $PROJECT_NAME"
        PROJECT_LINK=$(echo "${response}" | jq --raw-output '._meta .links[] | select(.rel=="versions") | .href')
    fi
}

# Find a project version given its name
function get_project_version()
{
    local response=$(curl -s --insecure -X GET --header "Content-Type:application/json" --header "Authorization: bearer $bearer_token" "$PROJECT_LINK?offset=0&limit=10000")
    response=$(echo "${response}" | jq --raw-output '.items[] | select(.versionName=='\""$VERSION_NAME"\"')')
    if [ -z "${response}" ]
    then
        echo "Could not find version: $VERSION_NAME for project: $PROJECT_NAME"
        echo "aborting..."
        exit 1
    else
        VERSION_LINK=$(echo "${response}" | jq --raw-output '._meta .href')
        echo "Found version: $VERSION_NAME"
    fi
}

function get_signature_scans()
{
    local response=$(curl -s --insecure -X GET --header "Content-Type:application/json" --header "Authorization: bearer $bearer_token" "$VERSION_LINK/source-trees?limit=9999")
    if [ -z "${response}" ]
    then
        echo "Could not find version: $VERSION_NAME for project: $PROJECT_NAME"
        echo "aborting..."
        exit 1
    else
        SIGNATURE_SCANS=$(echo "${response}" | jq -r '[.items[] | select(.nodeType!="DECLARED_COMPONENT") ]')
        local count=$(echo "${response}" | jq -r '[.items[] | select(.nodeType!="DECLARED_COMPONENT") ] | length')
        echo "Found $count scans to process"
    fi
}

function get_signature_scans_status()
{
    local response=$(curl -s --insecure -X GET --header "Content-Type:application/json" --header "Authorization: bearer $bearer_token" "$VERSION_LINK/source-trees?limit=9999")
    if [ -z "${response}" ]
    then
        echo "Could not find version: $VERSION_NAME for project: $PROJECT_NAME"
        echo "aborting..."
        exit 1
    else
        echo "${response}" | jq -r '.'
        SIGNATURE_SCANS=$(echo "${response}" | jq -r '[.items[] | select(.nodeType!="DECLARED_COMPONENT") ]')
        local count=$(echo "${response}" | jq -r '[.items[] | select(.nodeType!="DECLARED_COMPONENT") ] | length')
        echo "Found $count scans to process"
    fi
}

function get_match_data()
{
    MATCHED_COUNT=0
    TOTAL_FILES=0
    UNMATCHED_COUNT=0
    for row in $(echo "${SIGNATURE_SCANS}" | jq -r '.[] | @base64')
    do
        _jq()
        {
            echo ${row} | base64 --decode | jq -r ${1}
        }
        
        local scan=$(_jq '.')
        local scanName=$(echo "${scan}" | jq -r '.name')
        local scanType=$(echo "${scan}" | jq -r '.nodeType')
        echo "processing scan: $scanName type: $scanType"

        local scanLink=$(echo "${scan}" | jq -r '._meta.links[] | select(.rel=="source-entries").href')

        local response=$(curl -# --insecure -X GET --header "Content-Type:application/json" --header "Authorization: bearer $bearer_token" "$scanLink?limit=9999999&allDescendants=true")
        if [ -z "${response}" ]
        then
            echo "Could not get file data..."
        else
            local fileCount=$(echo "${response}" | jq -r '[.items[] | select(.type=="FILE")] | length')
            local unmatchedCount=$(echo "${response}" | jq -r '[.items[] | select((.type=="FILE") and .fileBomMatchType=="UNMATCHED" ) ] | length')
            local matchedCount=$(echo "${response}" | jq -r '[.items[] | select((.type=="FILE") and .fileBomMatchType!="UNMATCHED" ) ] | length')

            # For snippets
            if [ "${CONSIDER_SNIPPETS}" = true ]
            then
                # get all snippets
                local snippets=$(echo "${response}" | jq -r '[ .items[] | select(.type=="FILE") .fileSnippetBomComponents[] ]')
                if [ ! -z "${snippets}" ]
                then
                    # get path of reviewed snippets 
                    local confirmed_snippet_count=$(echo "${snippets}" | jq -r '[ .[] | select(.reviewStatus=="REVIEWED") .matchFileFullPath ] | unique | length')
                    matchedCount=$((matchedCount+confirmed_snippet_count))
                    unmatchedCount=$((unmatchedCount-confirmed_snippet_count))
                fi
            fi

            MATCHED_COUNT=$((MATCHED_COUNT+matchedCount))
            UNMATCHED_COUNT=$((UNMATCHED_COUNT+unmatchedCount))
            TOTAL_FILES=$((TOTAL_FILES+fileCount))
        fi
    done
}

function print_stats()
{
    local coverage=$((200*$MATCHED_COUNT/$TOTAL_FILES % 2 + 100*$MATCHED_COUNT/$TOTAL_FILES))
    echo "============================ STATISTICS =============================="
    echo "Total files: $TOTAL_FILES | Unmatched: $UNMATCHED_COUNT | Matched: $MATCHED_COUNT"
    echo "File level match coverage: $coverage %"
}

function main()
{
    echo "============================== Starting =============================="
    validate_inputs
    echo "----------------------------------------------------------------------"
    validate_requirements
    echo "----------------------------------------------------------------------"
    authenticate
    echo "----------------------------------------------------------------------"
    get_project
    echo "----------------------------------------------------------------------"
    get_project_version
    echo "----------------------------------------------------------------------"
    get_signature_scans
    echo "----------------------------------------------------------------------"
    get_signature_scans_status
    echo "----------------------------------------------------------------------"
    #get_match_data
    echo skipping get_match_data
    echo "----------------------------------------------------------------------"
    #print_stats
    echo skipping print_stats
    echo "======================================================================"
}

################################ MAIN ####################################
main
##########################################################################
