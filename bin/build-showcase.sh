#!/usr/bin/env bash

url_exists () {
  local auth_param exists url
  url="${1}"
  auth_param="${2:-}"
  exists=0
  if [[ "${auth_param}" ]]; then
    status=$(curl --silent -L -w '%{http_code}' -o '/dev/null' -u "${auth_param}" "${url}")
    result="$?"
  else
    status=$(curl --silent -L -w '%{http_code}' -o '/dev/null' "${url}")
    result="$?"
  fi
  if [[ '0' != "${result}" && '23' != "${result}" ]] || (( status >= 400 )); then
    exists=1
  fi
  return "${exists}"
}

main () {
  echo "# Javanile (showcase)" > README.md

  user=javanile
  #curl -s https://api.github.com/users/${user}/repos?per_page=100 | grep '"full_name":' | cut -d'"' -f4 > etc/repositories.list

  ## Classifier
  if [ -z "stop" ]; then
    remote="https://raw.githubusercontent.com"
    auth_param=
    while IFS="" read -r repo || [ -n "$repo" ]; do
      uri="${repo}/main"
      url="${remote}/${uri}"
      if url_exists "${url}/composer.json?$(date +%s)" "${auth_param}"; then
        echo $repo >> etc/repositories/php-package.list
      elif url_exists "${url}/package.json?$(date +%s)" "${auth_param}"; then
        echo $repo >> etc/repositories/nodejs-package.list
      elif url_exists "${url}/CNAME?$(date +%s)" "${auth_param}"; then
        echo $repo >> etc/repositories/website.list
      else
        echo $repo >> etc/repositories/miscellaneous.list
      fi
    done < etc/repositories.list
  fi

  ##
  while IFS="" read -r category || [ -n "$category" ]; do
    echo "### ${category#*=}" >> README.md
    while IFS="" read -r repository || [ -n "$repository" ]; do
      echo "* [$repository](https://github.com/$repository)" >> README.md
    done < etc/repositories/${category%=*}.list
  done < etc/categories.list
}

main
