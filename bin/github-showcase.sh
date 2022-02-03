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
  user=$(git config --get remote.origin.url | cut -d: -f2 | cut -d/ -f4)

  echo "# ${user} (showcase)" > README.md

  ## Get the list of repositories
  rm -f etc/repositories.list > /dev/null 2>&1
  for page in {1..2}; do
    curl -s "https://api.github.com/users/${user}/repos?page=${page}&per_page=2" | grep '"full_name":' | cut -d'"' -f4 >> etc/repositories.list
  done

  ## Repositories classifier
  if [ -s etc/repositories.list ]; then
    remote="https://raw.githubusercontent.com"
    auth_param=
    rm -f etc/repositories/*.list
    while IFS="" read -r repository || [ -n "$repository" ]; do
      uri="${repository}/main"
      url="${remote}/${uri}"
      if url_exists "${url}/composer.json?$(date +%s)" "${auth_param}"; then
        echo ${repository} >> etc/repositories/php-package.list
      elif url_exists "${url}/package.json?$(date +%s)" "${auth_param}"; then
        echo ${repository} >> etc/repositories/nodejs-package.list
      elif url_exists "${url}/CNAME?$(date +%s)" "${auth_param}"; then
        echo ${repository} >> etc/repositories/website.list
      elif url_exists "${url}/Dockerfile?$(date +%s)" "${auth_param}"; then
        echo ${repository} >> etc/repositories/docker.list
      else
        echo ${repository} >> etc/repositories/miscellaneous.list
      fi
    done < etc/repositories.list
  fi

  ## Generate sections
  while IFS="" read -r category || [ -n "$category" ]; do
    if [ -s etc/repositories/${category%=*}.list ]; then
      echo "### ${category#*=}" >> README.md
      while IFS="" read -r repository || [ -n "$repository" ]; do
        echo "* [$repository](https://github.com/$repository)" >> README.md
      done < etc/repositories/${category%=*}.list
    fi
  done < etc/categories.list
}

main
