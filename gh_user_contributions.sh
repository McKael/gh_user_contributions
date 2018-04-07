#! /bin/bash
#
# Get number of github contributions for a given account (FWIW...).
#
# As far as I know, there is no API for this information.
#
# For usage, try -h/--help or see below.
#
# Current external dependencies:
# - jq
# - curl
#
# This script should run with either bash or zsh.
#
# Mikael BERTHE, 2018-03

function usage {
    echo "Usage: gh_user_contributions.sh USER [N]"
    echo "N is optional, the maximum number of years to fetch."
}

## Check dependencies
if ! command -v jq > /dev/null 2>&1; then
    echo "This script requires the 'jq' utility." >&2
    exit 1
fi

if ! command -v curl > /dev/null 2>&1; then
    echo "This script requires the 'curl' utility." >&2
    exit 1
fi

## Helper functions

function user_creation_unixdate {
    local out="$(curl -s "https://api.github.com/users/$1")"
    local s="$(jq -r .created_at <<<"$out")"
    if ! grep -q 'T.*Z$' <<<$s; then
        local msg="$(jq -r .message <<<"$out")"
        if [[ -n $msg ]]; then
            echo "Server message: $msg">&2
        else
            echo "Could not find user">&2
        fi
        return 1
    fi
    date +%s -d "$s"
}

# get_contrib_page USER TODATE
function get_contrib_page {
    local u=$1
    local d=$2
    curl -s "https://github.com/users/$u/contributions?to=$d"
}

function yearly_contribs {
    typeset -i n c=0

    # Contributions for each day of the year
    year_contribs="$(get_contrib_page "$account" "$todate" |
        grep ' class="day" .* data-count=' |
        sed -E -e 's/.* data-count="([^"]+)" .*/\1/')"
    # Have to do this (temp. variable) for bash compatibility
    while read n; do (( c += n )); done <<<$(echo "$year_contribs")

    echo $c
}


## Main

# main ACCOUNT [NR_OF_YEARS]
main() {
    local account=$1

    if [[ -z $account || $account == "-h" || $account == "--help" ]]; then
        usage >&2
        exit
    fi

    typeset -i number_of_years=${2:-32}
    typeset -i count
    typeset -i account_creation_date

    account_creation_date=$(user_creation_unixdate "$account")
    if (( $? )); then
        echo "Failed to find account creation date.">&2
        exit 1
    fi

    #echo "Account creation date: $(date -d @$account_creation_date)">&2

    todate="$(date +"%Y-%m-%d")"
    for (( i = 0 ; i < number_of_years ; i++ )); do
        typeset -i y=$(yearly_contribs "$account" "$todate")
        (( count += y ))
        echo "* $todate: $y" >&2

        todate="$(date -d "$todate - 1 year" +"%Y-%m-%d")"

        # Stop when we're beyond account creation and there was no contribution
        (( $(date +%s -d "$todate") < account_creation_date && y == 0 )) && break
    done

    # Send only the total number to stdout
    echo "Total contributions:" >&2
    echo $count
}

main "$@"
