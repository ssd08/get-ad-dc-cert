#!/bin/bash




#-------------------------------------------------------------------------------
# COMMENTS
# Name: get-ad-dc-cert
#
# By: ssd08
#
# About: Gets the public-key certificate from one or more remote Active
#   Directory domain controllers.
#
# Requires:
#   - Bash
#   - OpenSSL >= 1.1.1
#   - sed (GNU sed) >= 3.5
#
# Tested:
#   - Bash 4.3
#   - OpenSSL 1.1.1
#   - sed 4.4
#-------------------------------------------------------------------------------




#-------------------------------------------------------------------------------
# FUNCTION
# About: prints name of script in shell.
# Accepts: void
# Returns: void
#-------------------------------------------------------------------------------
prnt_name()
{
  local char="="
  local -i i

  printf "\n"
  for (( i=1; i<=80; i++ )); do printf ${char}; done
  printf "\n                  Get Active Directory Domain Controller Cert\n\n"
  printf "                       Say, have you read the HIPAA today?\n\n"
  printf "  HIPAA at bed and HIPAA at rise, keeps me employed and the company"
  printf " un-fined.\n"
  for (( i=1; i<=80; i++ )); do printf ${char}; done
  printf "\n\n"

  return
}




#-------------------------------------------------------------------------------
# FUNCTION
# About: checks if OpenSSL is installed.
# Accepts: void
# Returns: void
#-------------------------------------------------------------------------------
chk_openssl_inst()
{
  local -i inst

  printf "Check for OpenSSL install...\n"
  which openssl &> /dev/null
  inst=$?
  if [ $inst -ne 0 ]; then
    printf "Error: OpenSSL not installed or not in default path.\n\n"
    exit 1
  fi

  return 
}




#-------------------------------------------------------------------------------
# FUNCTION
# About: checks if OpenSSL version is at least $min_ver.
# Accepts: void
# Returns: void
#-------------------------------------------------------------------------------
chk_openssl_ver()
{
  local ver
  local ver_num
  local -i min_ver=111
  
  printf "Check for OpenSSL version 1.1.1 or greater...\n"
  ver=$(openssl version | grep "OpenSSL [1-9]*.[1-9]*.[1-9]*")
  set $ver
  # OpenSSL version number dot-delimited.
  ver_num=$2
  
  # Delete dots.
  ver_num=${ver_num//./}
  if (( ver_num < min_ver )); then
    printf "Error: OpenSSL version 1.1.1 or greater required for this script.\n"
    printf "\n"
    exit 2
  fi

  return
}




#-------------------------------------------------------------------------------
# FUNCTION
# About: Checks if one or more domain controllers are defined in array $dc.
# Accepts: array $dc as unary argument.
# Returns: void
#-------------------------------------------------------------------------------
is_dc_def()
{
  local -a dc=($@)
  local -i dclen=${#dc[*]}
  if (( dclen < 1 )); then
    printf "\nError: one or more Active Directory domain controllers need to be"
    printf " defined in\nthe array \$dc in this script.\n\n"
    exit 3
  fi

  return
}




#-------------------------------------------------------------------------------
# FUNCTION
# About: replaces all occurrences of a char in a string with a different char.
# Accepts: string as unary argument.
# Returns: string with char(s) replaced.
#-------------------------------------------------------------------------------
replace_char()
{
  # Bash substring manipulation to replace '.'s with '_'s.
  local str=${1//./_}
  
  echo $str

  return
}




main()
{
  declare i
  declare -a dc=()
  dc[0]=dc1.corp.justforfeet.com
  dc[1]=dc2.corp.justforfeet.com
  dc[2]=dc3.corp.justforfeet.com
  declare certname
  # PEM armor
  declare -r HEADER="-----BEGIN CERTIFICATE-----"
  declare -r FOOTER="-----END CERTIFICATE-----"


  prnt_name

  sleep 1

  chk_openssl_inst

  #chk_openssl_ver

  is_dc_def ${dc[@]}

  for i in ${dc[@]}; do
    printf "\nGetting cert for domain controller $i\n"
    sleep 1
    printf "%s\n" "$HEADER" > $HOME/$i.cer
    openssl s_client -connect $i:636 < /dev/null | sed \
    '/^-----BEGIN CERTIFICATE-----$/,/^-----END CERTIFICATE-----$/!d;//d' \
    >> $HOME/$i.cer
    printf "%s\n" "$FOOTER" >> $HOME/$i.cer
    certname=$(replace_char $i)
    mv $HOME/$i.cer $HOME/$certname.cer
  done

  printf "\n%s\n\n" "Bye"
  exit 0
}
main "$@"
