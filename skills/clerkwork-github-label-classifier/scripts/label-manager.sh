#!/usr/bin/env bash
# shellcheck disable=SC2317

set -euo pipefail

SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_NAME
readonly LOG_DIR="${HOME}/.logs/github"
TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
readonly TIMESTAMP
readonly LOG_FILE="${LOG_DIR}/label-manager-${TIMESTAMP}.log"

mkdir -p "${LOG_DIR}"

readonly -a LABEL_DEFINITIONS=(
  'type:bug|9580FF|Bugfixes in the codebase when something is not working correctly.'
  'type:enhancement|9580FF|New enhancements and features not covered by a more specific type.'
  'type:dependencies|9580FF|Dependencies and upstream updates.'
  'type:documentation|9580FF|Technical, project, process, reference, or usage documentation.'
  'type:refactor|9580FF|Internal code restructuring without an intended behaviour change.'
  'type:data|9580FF|Datasets, migrations, transformations, imports, exports, or data preparation.'
  'type:tests|9580FF|Tests, test coverage, test infrastructure, or test maintenance.'
  'type:chore|9580FF|Maintenance, housekeeping, or routine work not covered by another type.'
  'type:security|9580FF|Security vulnerabilities, hardening, access control, secrets, or security-sensitive behaviour.'
  'type:performance|9580FF|Performance, speed, latency, resource usage, bundle size, throughput, or optimisation.'
  'type:accessibility|9580FF|Accessibility compliance, semantics, contrast, keyboard, or assistive-technology support.'
  'type:design|9580FF|Visual design, themes, styling, layout, branding, interaction presentation, or design systems.'
  'type:content|9580FF|User-facing editorial, marketing, or informational content and its organisation.'

  'status:unconfirmed|80FFEA|Reported but not yet confirmed.'
  'status:confirmed|80FFEA|Confirmed and accepted as valid work, but not yet in active implementation.'
  'status:in-progress|80FFEA|Work is currently in progress.'
  'status:blocked|80FFEA|Work cannot continue because of another issue, dependency, missing information, or decision.'
  'status:review|80FFEA|Work is ready for review or validation.'
  'status:done|66CCBB|Work is finished, but the issue remains open pending merge, push, deployment, or closure.'

  'resolution:duplicate|FF80BF|Closed because the same issue or request is already tracked elsewhere.'
  'resolution:invalid|FF80BF|Closed because the report or request is not valid.'
  'resolution:wont-fix|FF80BF|Closed with a deliberate decision not to implement or fix the understood issue.'
  'resolution:cancelled|FF80BF|Closed because previously intended or accepted work was withdrawn before completion.'
  'resolution:superseded|FF80BF|Closed because another decision, implementation, issue, or approach replaced this work.'
  'resolution:completed|CC6699|Closed because the requested work was completed.'

  'prio:critical|FF9580|Requires immediate attention.'
  'prio:high|FFCA80|High priority.'
  'prio:medium|FFFF80|Medium priority.'
  'prio:low|8AFF80|Low priority, including the default when no higher priority is supported.'

  'meta:question|708CA9|Further clarification, information, or discussion is needed.'
  'meta:help-wanted|708CA9|External or additional help is welcome.'
  'meta:keep-open|708CA9|Keep the issue open intentionally.'
)

usage() {
  cat <<EOF_USAGE
Usage:
  ${SCRIPT_NAME} [--repo OWNER/REPO ...] [--apply] [--clear] [--audit-only] [--verbose]

Description:
  Create or update Patrick's canonical GitHub issue label taxonomy in one or
  more repositories.

Default behaviour:
  * Runs in dry-run mode and makes no changes.
  * If no --repo is provided, detects the repository from remote.origin.url.

Authentication:
  * Uses an existing GH_TOKEN when set.
  * Otherwise exports GITHUB_TOKEN_CONTENT_PRIVATE as GH_TOKEN when available.
  * Otherwise gh uses GITHUB_TOKEN or its stored authentication.

Options:
  --repo OWNER/REPO   Repository to update. May be supplied multiple times.
  --apply             Apply changes instead of printing the commands.
  --clear             Delete all existing labels before creating the taxonomy.
                      Without --apply, deletions are shown only as dry-run output.
  --audit-only        Inspect and report the repository label situation without
                      creating, updating, or deleting labels.
  --verbose           Print additional progress information.
  --help              Show this help message.

Behaviour:
  * Uses 'gh label create --force' to create missing labels and update exact-name
    matches in place.
  * Does not delete obsolete or differently named labels unless --clear is used.
  * --clear removes every existing repository label, not only managed labels.
  * After each normal run, prints a label audit containing managed, missing,
    legacy, and repository-specific labels.
  * Legacy labels are unknown values inside a managed category namespace.

Examples:
  ${SCRIPT_NAME}
  ${SCRIPT_NAME} --apply
  ${SCRIPT_NAME} --apply --clear
  ${SCRIPT_NAME} --repo davidsneighbour/dotfiles
  ${SCRIPT_NAME} --repo davidsneighbour/dotfiles --apply
  ${SCRIPT_NAME} --repo davidsneighbour/dotfiles --audit-only
  ${SCRIPT_NAME} --repo davidsneighbour/dotfiles --repo davidsneighbour/kollitsch.dev --apply --verbose
EOF_USAGE
}

log() {
  local level="$1"
  shift
  printf '%s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${level}" "$*" | tee -a "${LOG_FILE}" >&2
}

info() {
  log "INFO" "$*"
}

error() {
  log "ERROR" "$*"
}

die() {
  error "$*"
  usage
  exit 1
}

verbose() {
  if [[ "${VERBOSE}" == "true" ]]; then
    info "$*"
  fi
}

require_command() {
  local command_name="$1"
  command -v "${command_name}" >/dev/null 2>&1 || die "Required command not found: ${command_name}"
}

configure_gh_auth() {
  if [[ -n "${GH_TOKEN:-}" ]]; then
    verbose "Using GH_TOKEN from the environment."
    return 0
  fi

  if [[ -n "${GITHUB_TOKEN_CONTENT_PRIVATE:-}" ]]; then
    export GH_TOKEN="${GITHUB_TOKEN_CONTENT_PRIVATE}"
    verbose "Using GITHUB_TOKEN_CONTENT_PRIVATE as GH_TOKEN."
    return 0
  fi

  if [[ -n "${GITHUB_TOKEN:-}" ]]; then
    verbose "Using GITHUB_TOKEN from the environment."
    return 0
  fi

  verbose "Using stored gh authentication when available."
}

parse_github_repo_from_url() {
  local remote_url="$1"
  local repository=""

  case "${remote_url}" in
    git@github.com:*)
      repository="${remote_url#git@github.com:}"
      ;;
    ssh://git@github.com/*)
      repository="${remote_url#ssh://git@github.com/}"
      ;;
    https://github.com/*)
      repository="${remote_url#https://github.com/}"
      ;;
    http://github.com/*)
      repository="${remote_url#http://github.com/}"
      ;;
    *)
      return 1
      ;;
  esac

  repository="${repository%.git}"
  repository="${repository%/}"

  if [[ "${repository}" =~ ^[^/]+/[^/]+$ ]]; then
    printf '%s\n' "${repository}"
    return 0
  fi

  return 1
}

detect_current_repo() {
  local remote_url=""
  local repository=""

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || die "No --repo provided and the current directory is not inside a Git repository."

  remote_url="$(git config --get remote.origin.url 2>/dev/null || true)"
  [[ -n "${remote_url}" ]] \
    || die "No --repo provided and remote.origin.url is not configured."

  repository="$(parse_github_repo_from_url "${remote_url}")" \
    || die "Could not derive OWNER/REPO from remote.origin.url: ${remote_url}"

  printf '%s\n' "${repository}"
}

run_gh_label_create() {
  local repository="$1"
  local name="$2"
  local colour="$3"
  local description="$4"

  if [[ "${APPLY}" != "true" ]]; then
    printf 'DRY-RUN gh label create %q --repo %q --color %q --description %q --force\n' \
      "${name}" "${repository}" "${colour}" "${description}"
    return 0
  fi

  gh label create "${name}" \
    --repo "${repository}" \
    --color "${colour}" \
    --description "${description}" \
    --force >/dev/null
}

run_gh_label_delete() {
  local repository="$1"
  local name="$2"

  if [[ "${APPLY}" != "true" ]]; then
    printf 'DRY-RUN gh label delete %q --repo %q --yes\n' "${name}" "${repository}"
    return 0
  fi

  gh label delete "${name}" --repo "${repository}" --yes >/dev/null
}

apply_labels_to_repo() {
  local repository="$1"
  local definition=""
  local name=""
  local colour=""
  local description=""

  info "Processing ${repository}"

  for definition in "${LABEL_DEFINITIONS[@]}"; do
    IFS='|' read -r name colour description <<< "${definition}"
    run_gh_label_create "${repository}" "${name}" "${colour}" "${description}"
  done
}

clear_labels_for_repo() {
  local repository="$1"
  local label_name=""

  info "Clearing all existing labels from ${repository}"

  while IFS= read -r label_name; do
    [[ -n "${label_name}" ]] || continue
    run_gh_label_delete "${repository}" "${label_name}"
  done < <(gh api --paginate "repos/${repository}/labels?per_page=100" --jq '.[].name')
}

label_is_canonical() {
  local candidate="$1"
  local definition=""
  local canonical_name=""
  local _ignored_colour=""
  local _ignored_description=""

  for definition in "${LABEL_DEFINITIONS[@]}"; do
    IFS='|' read -r canonical_name _ignored_colour _ignored_description <<< "${definition}"
    if [[ "${candidate}" == "${canonical_name}" ]]; then
      return 0
    fi
  done

  return 1
}

label_uses_managed_namespace() {
  local candidate="$1"

  case "${candidate}" in
    type:*|status:*|resolution:*|prio:*|meta:*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

print_label_list() {
  local heading="$1"
  shift
  local -a labels=("$@")
  local label=""

  printf '%s (%d):\n' "${heading}" "${#labels[@]}"
  if [[ ${#labels[@]} -eq 0 ]]; then
    printf '  - none\n'
    return 0
  fi

  for label in "${labels[@]}"; do
    printf '  - %s\n' "${label}"
  done
}

audit_labels_for_repo() {
  local repository="$1"
  local existing_name=""
  local definition=""
  local canonical_name=""
  local _ignored_colour=""
  local _ignored_description=""
  local found="false"
  local -a existing_labels=()
  local -a installed_labels=()
  local -a missing_labels=()
  local -a legacy_labels=()
  local -a custom_labels=()

  while IFS= read -r existing_name; do
    [[ -n "${existing_name}" ]] || continue
    existing_labels+=("${existing_name}")

    if label_is_canonical "${existing_name}"; then
      installed_labels+=("${existing_name}")
    elif label_uses_managed_namespace "${existing_name}"; then
      legacy_labels+=("${existing_name}")
    else
      custom_labels+=("${existing_name}")
    fi
  done < <(gh api --paginate "repos/${repository}/labels?per_page=100" --jq '.[].name' | LC_ALL=C sort)

  for definition in "${LABEL_DEFINITIONS[@]}"; do
    IFS='|' read -r canonical_name _ignored_colour _ignored_description <<< "${definition}"
    found="false"
    for existing_name in "${existing_labels[@]}"; do
      if [[ "${existing_name}" == "${canonical_name}" ]]; then
        found="true"
        break
      fi
    done
    if [[ "${found}" != "true" ]]; then
      missing_labels+=("${canonical_name}")
    fi
  done

  printf '\nLabel situation for %s\n' "${repository}"
  printf '%s\n' '----------------------------------------'
  printf 'Canonical taxonomy: %d labels\n' "${#LABEL_DEFINITIONS[@]}"
  printf 'Installed canonical: %d\n' "${#installed_labels[@]}"
  printf 'Missing canonical: %d\n' "${#missing_labels[@]}"
  printf 'Legacy managed-name labels: %d\n' "${#legacy_labels[@]}"
  printf 'Repository-specific labels: %d\n' "${#custom_labels[@]}"

  print_label_list 'Missing canonical labels' "${missing_labels[@]}"
  print_label_list 'Legacy labels requiring review' "${legacy_labels[@]}"
  print_label_list 'Repository-specific labels preserved' "${custom_labels[@]}"

  if [[ ${#missing_labels[@]} -eq 0 && ${#legacy_labels[@]} -eq 0 ]]; then
    printf 'Result: taxonomy is complete and no legacy managed labels were found.\n'
  elif [[ ${#legacy_labels[@]} -eq 0 ]]; then
    printf 'Result: no legacy managed labels found; canonical labels are still missing.\n'
  else
    printf 'Result: review legacy labels manually; this script does not delete or rename them.\n'
  fi
}

VERBOSE="false"
APPLY="false"
CLEAR="false"
AUDIT_ONLY="false"
declare -a REPOSITORIES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      shift
      [[ $# -gt 0 ]] || die "Missing value for --repo"
      REPOSITORIES+=("$1")
      ;;
    --apply)
      APPLY="true"
      ;;
    --clear)
      CLEAR="true"
      ;;
    --audit-only)
      AUDIT_ONLY="true"
      ;;
    --verbose)
      VERBOSE="true"
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      die "Unknown option: $1"
      ;;
  esac
  shift
done

main() {
  local detected_repository=""
  local repository=""

  require_command "gh"
  require_command "git"
  configure_gh_auth

  gh auth status >/dev/null 2>&1 \
    || die "GitHub CLI is not authenticated. Set GITHUB_TOKEN_CONTENT_PRIVATE, GH_TOKEN, or run 'gh auth login'."

  verbose "Log file: ${LOG_FILE}"
  verbose "Apply mode: ${APPLY}"
  verbose "Clear mode: ${CLEAR}"
  verbose "Audit-only mode: ${AUDIT_ONLY}"

  if [[ "${AUDIT_ONLY}" == "true" ]]; then
    info "Running in audit-only mode. No labels will be changed."
  elif [[ "${APPLY}" != "true" ]]; then
    info "Running in dry-run mode. Use --apply to execute changes."
  fi

  if [[ ${#REPOSITORIES[@]} -eq 0 ]]; then
    detected_repository="$(detect_current_repo)"
    REPOSITORIES=("${detected_repository}")
    info "Using detected repository: ${detected_repository}"
  fi

  for repository in "${REPOSITORIES[@]}"; do
    if [[ "${AUDIT_ONLY}" != "true" ]]; then
      if [[ "${CLEAR}" == "true" ]]; then
        clear_labels_for_repo "${repository}"
      fi
      apply_labels_to_repo "${repository}"
    fi

    audit_labels_for_repo "${repository}"
  done

  if [[ "${AUDIT_ONLY}" == "true" ]]; then
    info "Label audit completed."
  elif [[ "${APPLY}" == "true" ]]; then
    info "Label update and audit completed."
  else
    info "Dry run and current-state audit completed."
  fi
}

main "$@"
