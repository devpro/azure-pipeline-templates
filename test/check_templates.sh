#!/usr/bin/env bash
# Checks the templates against the rules of CONTRIBUTING.md, which are the promises of this repository to the pipelines using them.
# Azure only checks that a template is valid, so each check guards one promise against a regression.
# Needs bash, git and yq (mikefarah).

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# parameters that no job of azure-pipelines.yml sets, with the reason
declare -A UNTESTED_PARTS=(
  [dotnet-quality:name]="Azure names the job from it, which a second job of the template would only check for Azure"
  [dotnet-quality:pool]="another pool needs an agent pool of an organization, which the default hosted pool stands for"
  [dotnet-quality:timeoutInMinutes]="Azure cancels the job, which a test would only check for Azure"
  [dotnet-quality:dotnetVersion]="the fixture builds the same with every patch of 10.0, so no job tells two versions apart"
)

# files that quote the words the writing rules forbid, or are not written here
writing_exceptions=" LICENSE AGENTS.md test/check_templates.sh "

failures=0
fail() {
  echo "$1: $2" >&2
  failures=$((failures + 1))
}

check_template() {
  local file="$1" declared used name
  declared="$(yq '.parameters[].name' "$file" | sort)"
  # shellcheck disable=SC2016 # matches the expressions as written, which Azure expands
  used="$(grep -o '\${{ *parameters\.[A-Za-z0-9_]*' "$file" | sed 's/.*parameters\.//' | sort -u || true)"
  while read -r name; do fail "$file" "parameter $name is used and not declared"; done < <(comm -13 <(echo "$declared") <(echo "$used") | grep . || true)
  while read -r name; do fail "$file" "parameter $name is declared and not used"; done < <(comm -23 <(echo "$declared") <(echo "$used") | grep . || true)
  while read -r name; do fail "$file" "parameter $name has no type"; done < <(yq '.parameters[] | select((.type // "") == "") | .name' "$file")
  while read -r name; do fail "$file" "parameter $name has no displayName"; done < <(yq '.parameters[] | select((.displayName // "") == "") | .name' "$file")
  while read -r name; do fail "$file" "parameter $name is not in camel case"; done < <(grep -vxE '[a-z][A-Za-z0-9]*' <<< "$declared" || true)

  while read -r name; do fail "$file" "job $name has no timeoutInMinutes"; done < <(yq '.jobs[] | select(has("job") and (has("timeoutInMinutes") | not)) | .job' "$file")
  check_steps "$file" "$file"
}

# checks the steps of a template, the steps a parameter inserts being those of the pipeline using it
check_steps() {
  local file="$1" label="$2"
  # Azure pastes a parameter into the shell code as text, where a variable of env: stays data
  # shellcheck disable=SC2016 # matches the expressions as written, which Azure expands
  if yq '.. | select(tag == "!!map") | (.bash, .script, .pwsh, .powershell) | select(. != null)' "$file" | grep -q '\${{'; then
    fail "$label" "a script uses a template expression, which goes through env: instead"
  fi
  while read -r name; do fail "$label" "step \"$name\" lets the code it runs set variables, which target.settableVariables: none stops"; done < <(
    yq '.. | select(tag == "!!map" and (has("bash") or has("script") or has("pwsh") or has("powershell")) and .target.settableVariables != "none") | .displayName // "unnamed"' "$file")
  if [[ "$(yq '[.. | select(tag == "!!map" and has("checkout") and .persistCredentials != false)] | length' "$file")" != 0 ]]; then
    fail "$label" "a checkout keeps the token in the git configuration, which persistCredentials: false stops"
  fi
}

check_catalog() {
  local templates="$1" tested name set_parameters part declared
  tested="$(yq '.jobs[] | select(has("template")) | .template' azure-pipelines.yml | sed -E 's|^jobs/(.*)\.yml$|\1|' | sort -u)"
  while read -r name; do fail azure-pipelines.yml "template $name is not used, so no job tests it"; done < <(comm -23 <(echo "$templates") <(echo "$tested") | grep . || true)
  for name in $templates; do
    grep -qx "## $name" docs/templates.md || fail docs/templates.md "template $name has no section"
    grep -qxF -- "- [$name](docs/templates.md#$name)" README.md || fail README.md "template $name has no link to its section"
  done

  # lists each parameter that a job of the pipeline sets, as template:parameter
  # shellcheck disable=SC2016 # $t is a variable of yq
  set_parameters="$(yq '.jobs[] | select(has("template")) | .template as $t | (.parameters // {}) | keys | .[] | ($t | sub("^jobs/", "") | sub("\.yml$", "")) + ":" + .' azure-pipelines.yml | sort -u)"
  for name in $templates; do
    declared="$(yq '.parameters[].name' "jobs/$name.yml")"
    for part in $declared; do
      part="$name:$part"
      if grep -qx "$part" <<< "$set_parameters"; then
        [[ -z "${UNTESTED_PARTS[$part]:-}" ]] || fail test/check_templates.sh "$part is tested, and listed in UNTESTED_PARTS"
      elif [[ -z "${UNTESTED_PARTS[$part]:-}" ]]; then
        fail azure-pipelines.yml "no job sets $part, which UNTESTED_PARTS does not list"
      fi
    done
  done
  for part in "${!UNTESTED_PARTS[@]}"; do
    [[ -f "jobs/${part%%:*}.yml" ]] || fail test/check_templates.sh "UNTESTED_PARTS lists $part, of no template"
  done
}

check_writing() {
  local file
  while read -r file; do
    [[ "$writing_exceptions" == *" $file "* || ! -f "$file" ]] && continue
    if grep -q $'–\|—' "$file"; then fail "$file" "has an em dash or an en dash"; fi
    if grep -qiwE 'you|your|yours|yourself' "$file"; then fail "$file" "speaks to the reader in the second person"; fi
  done < <(git ls-files --cached --others --exclude-standard)
}

templates=""
for path in jobs/*.yml; do
  check_template "$path"
  templates+="$(basename "$path" .yml)"$'\n'
done
templates="$(sort <<< "$templates" | grep .)"
check_catalog "$templates"
check_writing

echo "$(wc -l <<< "$templates") templates checked, $failures failures"
[[ $failures -eq 0 ]]
