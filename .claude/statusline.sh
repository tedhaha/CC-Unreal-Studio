#!/usr/bin/env bash
# CCGS Status Line — Opus4.7/1M | ctx N% | branch | dir | Stage [| Epic > Feature > Task]

input=$(cat)

if command -v jq &>/dev/null; then
  model_display=$(echo "$input" | jq -r '.model.display_name // ""')
  used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
  cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
else
  model_display=$(echo "$input" | grep -oE '"display_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
  used_pct=$(echo "$input" | grep -oE '"used_percentage"[[:space:]]*:[[:space:]]*[0-9.]+' | head -1 | sed 's/.*: *//')
  cwd=$(echo "$input" | grep -oE '"current_dir"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*: *"//;s/"$//')
fi

cwd=$(echo "$cwd" | tr '\\' '/' 2>/dev/null)
[ -z "$cwd" ] && cwd="."

# Model: "Claude Opus 4.7 (1M context)" → "Opus4.7/1M"
model="${model_display#Claude }"
model=$(echo "$model" | sed -E 's# \(([0-9]+M) context\)#/\1#')
model=$(echo "$model" | tr -d ' ')
[ -z "$model" ] && model="?"

# Context %
if [ -n "$used_pct" ]; then
  pct_int=$(printf "%.0f" "$used_pct" 2>/dev/null || echo "$used_pct")
  ctx="ctx ${pct_int}%"
else
  ctx="ctx --"
fi

# Git branch
branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
if [ -n "$branch" ] && [ ${#branch} -gt 30 ]; then
  branch="...${branch: -27}"
fi

# Last 2 path segments
parent=$(basename "$(dirname "$cwd")")
leaf=$(basename "$cwd")
if [ -n "$parent" ] && [ "$parent" != "." ] && [ "$parent" != "/" ]; then
  dir="${parent}/${leaf}"
else
  dir="${leaf}"
fi

# Stage: production/stage.txt 우선, 없으면 artifact 기반 추정
stage_file="$cwd/production/stage.txt"
stage=""
[ -f "$stage_file" ] && stage=$(head -1 "$stage_file" | tr -d '\r\n')

if [ -z "$stage" ]; then
  has_concept=false; has_systems=false; engine_configured=false; has_adrs=false
  [ -f "$cwd/design/gdd/game-concept.md" ] && has_concept=true
  [ -f "$cwd/design/gdd/systems-index.md" ] && has_systems=true
  if [ -f "$cwd/.claude/docs/technical-preferences.md" ]; then
    if grep -m1 '^\*\*Engine\*\*:' "$cwd/.claude/docs/technical-preferences.md" 2>/dev/null | grep -qv "TO BE CONFIGURED"; then
      engine_configured=true
    fi
  fi
  ls "$cwd/docs/architecture/"adr-*.md 2>/dev/null | head -1 | grep -q . && has_adrs=true

  if [ "$has_adrs" = true ]; then stage="Pre-Production"
  elif [ "$engine_configured" = true ]; then stage="Technical Setup"
  elif [ "$has_systems" = true ]; then stage="Systems Design"
  else stage="Concept"
  fi
fi

# Production+ 단계에서만 Epic/Feature/Task breadcrumb
breadcrumb=""
if [ "$stage" = "Production" ] || [ "$stage" = "Polish" ] || [ "$stage" = "Release" ]; then
  state_file="$cwd/production/session-state/active.md"
  if [ -f "$state_file" ]; then
    in_block=false; epic=""; feature=""; task=""
    while IFS= read -r line; do
      case "$line" in
        *"<!-- STATUS -->"*) in_block=true; continue ;;
        *"<!-- /STATUS -->"*) break ;;
      esac
      if [ "$in_block" = true ]; then
        case "$line" in
          Epic:*) epic=$(echo "$line" | sed 's/^Epic: *//') ;;
          Feature:*) feature=$(echo "$line" | sed 's/^Feature: *//') ;;
          Task:*) task=$(echo "$line" | sed 's/^Task: *//') ;;
        esac
      fi
    done < "$state_file"
    parts=""
    [ -n "$epic" ] && parts="$epic"
    [ -n "$feature" ] && parts="${parts:+$parts > }$feature"
    [ -n "$task" ] && parts="${parts:+$parts > }$task"
    [ -n "$parts" ] && breadcrumb=" | $parts"
  fi
fi

branch_part=""
[ -n "$branch" ] && branch_part=" | ${branch}"
printf "%s" "${model} | ${ctx}${branch_part} | ${dir} | ${stage}${breadcrumb}"
