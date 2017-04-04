#!/bin/bash
echo -e "Content-type: text/html\n"

# (internal) routine to store POST data
function cgi_get_POST_vars()
{
    # only handle POST requests here
    [ "$REQUEST_METHOD" != "POST" ] && return

    # save POST variables (only first time this is called)
    [ ! -z "$QUERY_STRING_POST" ] && return

    # skip empty content
    [ -z "$CONTENT_LENGTH" ] && return

    # check content type
    # FIXME: not sure if we could handle uploads with this..
    [ "${CONTENT_TYPE}" != "application/x-www-form-urlencoded" ] && \
        echo "bash.cgi warning: you should probably use MIME type "\
             "application/x-www-form-urlencoded!" 1>&2

    # convert multipart to urlencoded
    local handlemultipart=0 # enable to handle multipart/form-data (dangerous?)
    if [ "$handlemultipart" = "1" -a "${CONTENT_TYPE:0:19}" = "multipart/form-data" ]; then
        boundary=${CONTENT_TYPE:30}
        read -N $CONTENT_LENGTH RECEIVED_POST
        # FIXME: don't use awk, handle binary data (Content-Type: application/octet-stream)
        QUERY_STRING_POST=$(echo "$RECEIVED_POST" | awk -v b=$boundary 'BEGIN { RS=b"\r\n"; FS="\r\n"; ORS="&" }
           $1 ~ /^Content-Disposition/ {gsub(/Content-Disposition: form-data; name=/, "", $1); gsub("\"", "", $1); print $1"="$3 }')

    # take input string as is
    else
        read -N $CONTENT_LENGTH QUERY_STRING_POST
    fi

    return
}

# # (internal) routine to decode urlencoded strings
# function cgi_decodevar()
# {
#     [ $# -ne 1 ] && return
#     local v t h
#     # replace all + with whitespace and append %%
#     t="${1//+/ }%%"
#     while [ ${#t} -gt 0 -a "${t}" != "%" ]; do
#         v="${v}${t%%\%*}" # digest up to the first %
#         t="${t#*%}"       # remove digested part
#         # decode if there is anything to decode and if not at end of string
#         if [ ${#t} -gt 0 -a "${t}" != "%" ]; then
#             h=${t:0:2} # save first two chars
#             t="${t:2}" # remove these
#             v="${v}"`echo -e \\\\x${h}` # convert hex to special char
#         fi
#     done
#     # return decoded string
#     echo "${v}"
#     return
# }

# routine to get variables from http requests
# usage: cgi_getvars method varname1 [.. varnameN]
# method is either GET or POST or BOTH
# the magic varible name ALL gets everything
function cgi_getvars()
{
    [ $# -lt 2 ] && return
    local q p k v s
    # get query
    case $1 in
        GET)
            [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
            ;;
        POST)
            cgi_get_POST_vars
            [ ! -z "${QUERY_STRING_POST}" ] && q="${QUERY_STRING_POST}&"
            ;;
        BOTH)
            [ ! -z "${QUERY_STRING}" ] && q="${QUERY_STRING}&"
            cgi_get_POST_vars
            [ ! -z "${QUERY_STRING_POST}" ] && q="${q}${QUERY_STRING_POST}&"
            ;;
    esac
    shift
    s=" $* "
    # parse the query data
    while [ ! -z "$q" ]; do
        p="${q%%&*}"  # get first part of query string
        k="${p%%=*}"  # get the key (variable name) from it
        v="${p#*=}"   # get the value from it
        q="${q#$p&*}" # strip first part from query string
        # decode and assign variable if requested
        [ "$1" = "ALL" -o "${s/ $k /}" != "$s" ] && \
#            export "$k"="`cgi_decodevar \"$v\"`"
            export "$k"="$v"
    done
    return
}

# register all GET and POST variables
cgi_getvars BOTH ALL

case "$command" in
  genkey)
    openssl genrsa -out /tmp/pindanetZsYTpr5e9CXbcLCJCXNUxSFH1TdLYQqwrsa_priv.pem 2048
    openssl rsa -pubout -in /tmp/pindanetZsYTpr5e9CXbcLCJCXNUxSFH1TdLYQqwrsa_priv.pem -out /tmp/pindanetZsYTpr5e9CXbcLCJCXNUxSFH1TdLYQqwrsa_pub.pem
    cat /tmp/pindanetZsYTpr5e9CXbcLCJCXNUxSFH1TdLYQqwrsa_pub.pem
    exit
    ;;
esac
pincode=`echo "$encpin" | openssl base64 -d | openssl rsautl -decrypt -inkey /tmp/pindanetZsYTpr5e9CXbcLCJCXNUxSFH1TdLYQqwrsa_priv.pem`

# { myCode=$(</dev/stdin); } << EOF
# case "\$command" in
#   system)
#     echo "<button onclick=\"location.reload();\">Vernieuwen</button>
#         <button onclick=\"remoteCommand(event,'reboot');\">Herstart</button>
#         <button onclick=\"remoteCommand(event,'halt');\">Uitschakelen</button>"
#     ;;
#   reboot)
#     sudo /sbin/shutdown -r now
#     ;;
#   halt)
#     sudo /sbin/shutdown -h now
#     ;;
#   saveThermostat)
#     echo $jason;;
#   *)
#     echo Error
# esac
# EOF

# encoderen
# enc=`echo -n "$myCode" | openssl enc -e -aes-256-cbc -a -salt -pass pass:$pincode`

# Voorbeeld met pincode: 123
# Opgelet: $command wordt \$command

enc='U2FsdGVkX1+lvGGzsjTCC1h59kcdMpUBxNaKtQSxvgcSjVHPgpb2yEBk/JSSaC6j
w7NpsUFcTXqkdi4KoTeOvd5vgUQ3QVOmLAoRS/Tu0sVg9KI8Uky3ZQu+gAN9unaI
u+uUceoAgJN2KUgTP+SF2mqaBxpgKx3j79ekYEGAyUq1wRTHRNXCNq6fD5x5J30z
0KJgJd4nzs/W8IdHDYh9ESTk3Xjv4NqEQ13+tve8F+3h5wk7TYwOuviOi745j4jt
SZzwva9ENgcU4nrI8VNhfQhtoMLkJPA1RJluEXlQOtdkP4gvNgvAnoTHtF0XHIeC
v6CScmkIfQ8NrblFYDUZ7d6Nr0IJt0neXYwR5AfdAYnhLkUouVVDJ2hk9M5g/bOk
+Zttc66Q73MywMSPlnbze2/8LVBHVrlVWpIwEz97uvzoq2CnwKIOvTKsRTEf+fWR
8g14G9OfpY0SyoaeNdhxYhh+jMjqm5dijWKBDSIeIVlrY+FauDy4exAIsRHwvw4x
4E33oxYtKvdIdgEVyWbIlNauQguOTWuwe2RfsI72NijQqgjJUoXlP//ixB+8vT8A'

# decoderen
dec=`echo "$enc" | openssl enc -d -aes-256-cbc -a -salt -pass pass:$pincode`

eval "$dec"
