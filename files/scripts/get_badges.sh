#!/usr/bin/env bash
set -euo pipefail

badge_dir=${BADGE_DIR:-badges}
repository=${GITHUB_REPOSITORY:-}
owner=${GITHUB_REPOSITORY_OWNER:-}
badge_repository=${BADGE_REPOSITORY:-}
badge_branch=${BADGE_BRANCH:-}

if [[ -z "$repository" ]]; then
  repository=$(git config --get remote.origin.url |
    sed -E 's#^https://github.com/##; s#^git@github.com:##; s#\.git$##')
fi
if [[ -z "$owner" ]]; then
  owner=${repository%%/*}
fi
if [[ -z "$badge_repository" ]]; then
  badge_repository=$repository
fi
if [[ -z "$badge_branch" ]]; then
  badge_branch=${GITHUB_HEAD_REF:-${GITHUB_REF_NAME:-$(git branch --show-current)}}
fi

if [[ -z "$repository" || "$repository" != */* ]]; then
  printf 'error: set GITHUB_REPOSITORY to owner/repository or configure origin\n' >&2
  exit 1
fi
if ! command -v gh >/dev/null || ! command -v jq >/dev/null; then
  printf 'error: get_badges.sh requires both gh and jq\n' >&2
  exit 1
fi

mkdir -p "$badge_dir"
find "$badge_dir" -type f -name '*.json' -delete

declare -A image_channels=()
while IFS= read -r recipe; do
  image=$(sed -n 's/^name: *//p' "$recipe" | head -n 1)
  [[ -n "$image" ]] || continue

  channels=$(grep -hE '^[[:space:]]+- (stable|testing|latest)$' "$recipe" |
    sed 's/^[[:space:]]*- //' | sort -u || true)
  for channel in $channels; do
    image_channels["$image $channel"]=1
  done
done < <(find recipes -maxdepth 3 -type f -name '*.yml' \
  ! -name 'recipe-example.yml' ! -empty | sort)

for image in $(printf '%s\n' "${!image_channels[@]}" | awk '{print $1}' | sort -u); do
  versions_file=$(mktemp)
  trap 'rm -f "$versions_file"' EXIT

  if ! gh api --paginate \
      "/users/${owner}/packages/container/${image}/versions?per_page=100" \
      --jq '.[]' | jq -s '.' >"$versions_file"; then
    printf 'warning: could not read package metadata for %s\n' "$image" >&2
    printf '[]\n' >"$versions_file"
  fi

  for channel in stable testing latest; do
    output="${badge_dir}/${image}-${channel}.json"
    if [[ -z "${image_channels["$image $channel"]+set}" ]]; then
      version='not configured'
      color='lightgrey'
    else
      version=$(jq -r --arg channel "$channel" '
        [.[] | select(.metadata.container.tags != null)
        | select(any(.metadata.container.tags[]; . == $channel or startswith($channel + "-")))]
        | sort_by(.created_at) | last
        | if . == null then ""
          else ([.metadata.container.tags[] |
            select(. == $channel or startswith($channel + "-"))] | first)
            + " · " + (.created_at | split("T")[0])
          end
      ' "$versions_file")
      if [[ -z "$version" ]]; then
        version='not published'
        color='lightgrey'
      else
        color='brightgreen'
      fi
    fi

    jq -n \
      --arg label "$channel" \
      --arg message "$version" \
      --arg color "$color" \
      '{schemaVersion: 1, label: $label, message: $message, color: $color}' \
      >"$output"
  done

  rm -f "$versions_file"
  trap - EXIT
done

printf 'Generated badge files in %s for %s\n' "$badge_dir" "$repository"

if [[ "${UPDATE_README:-1}" == "1" && -n "$badge_branch" ]]; then
  encoded_repository=${badge_repository//\//%2F}
  encoded_branch=${badge_branch//\//%2F}
  badge_prefix="https%3A%2F%2Fraw.githubusercontent.com%2F${encoded_repository}%2F${encoded_branch}%2Fbadges%2F"
  for readme in README.md docs/README-TR.md; do
    [[ -f "$readme" ]] || continue
    sed -i -E \
      "s#https%3A%2F%2Fraw\\.githubusercontent\\.com%2F[^%]+%2F[^%]+%2F[^%]+%2Fbadges%2F#${badge_prefix}#g" \
      "$readme"
  done
  printf 'Updated README badge links for %s at %s\n' "$badge_repository" "$badge_branch"
fi
