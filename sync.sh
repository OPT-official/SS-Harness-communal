#!/usr/bin/env bash
# sync.sh — OPT archive 자동 동기화
# 사용법: bash sync.sh <학기폴더>
#   예)   bash sync.sh 2026-fall
#
# 동작:
#   1. <학기폴더> 안의 모든 .pptx 를 PDF로 변환
#   2. 새 PDF를 INDEX.md 표에 자동 추가
#   3. git add + commit + push
#
# 원본 .pptx 는 로컬에만 남고 GitHub엔 안 올라감(.gitignore 처리).

set -euo pipefail

# ---- 설정 ----
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX="$REPO_DIR/INDEX.md"
ANCHOR="<!-- INDEX-AUTO"

# ---- LibreOffice 자동탐지 ----
# 설치 위치는 PC마다 다를 수 있음. 여러 후보 + PATH 순으로 탐색.
find_soffice() {
  local candidates=(
    "/c/Program Files/LibreOffice/program/soffice.exe"
    "/c/Program Files (x86)/LibreOffice/program/soffice.exe"
    "$LOCALAPPDATA/Programs/LibreOffice/program/soffice.exe"
  )
  local c
  for c in "${candidates[@]}"; do
    [ -x "$c" ] && { echo "$c"; return 0; }
  done
  # PATH에 있으면 사용
  if command -v soffice >/dev/null 2>&1; then
    command -v soffice; return 0
  fi
  return 1
}

# ---- 인자 확인 ----
if [ $# -lt 1 ]; then
  echo "사용법: bash sync.sh <학기폴더>   (예: bash sync.sh 2026-fall)"
  exit 1
fi
SEM="$1"
TARGET="$REPO_DIR/$SEM"

SOFFICE="$(find_soffice || true)"
if [ -z "$SOFFICE" ]; then
  echo "❌ LibreOffice 못 찾음. 설치했는지 확인하세요."
  echo "   (설치 위치가 특이하면 sync.sh find_soffice 후보에 경로 추가)"
  exit 1
fi

mkdir -p "$TARGET"

# ---- 0. 최신 받기 (충돌 방지) ----
cd "$REPO_DIR"
echo "⬇️  git pull..."
if ! git pull --rebase --autostash origin main; then
  echo "❌ git pull 실패 (충돌 가능). 수동으로 해결 후 다시 실행하세요."
  exit 1
fi

# ---- 1. PPTX → PDF 변환 (바뀐 것만) ----
# PDF가 없거나 pptx가 더 최신일 때만 변환. 안 바뀐 파일 재변환 안 함
# → 불필요한 새 사본(히스토리 bloat) 방지 + 속도 향상.
shopt -s nullglob
all_pptx=("$TARGET"/*.pptx "$TARGET"/*.PPTX)
to_convert=()
for pptx in "${all_pptx[@]}"; do
  pdf="${pptx%.*}.pdf"
  if [ ! -e "$pdf" ] || [ "$pptx" -nt "$pdf" ]; then
    to_convert+=("$pptx")
  else
    echo "  ⏭️  스킵(안 바뀜): $(basename "$pptx")"
  fi
done

if [ ${#to_convert[@]} -eq 0 ]; then
  echo "ℹ️  변환할 pptx 없음 (전부 최신)."
else
  echo "🔄 변환 중 (${#to_convert[@]}개)..."
  # 주의: 변환 중 LibreOffice GUI가 열려있으면 실패할 수 있음 → 닫고 실행
  "$SOFFICE" --headless --convert-to pdf --outdir "$TARGET" "${to_convert[@]}"
fi

# ---- 2. INDEX.md 갱신 ----
strip_topic() {           # 02_CNN -> CNN, 03_RNN_LSTM -> RNN_LSTM
  echo "$1" | sed -E 's/^[0-9]+[_-]?//'
}

new_rows=""
for pdf in "$TARGET"/*.pdf; do
  [ -e "$pdf" ] || continue
  base="$(basename "$pdf")"
  # 이미 INDEX에 있으면 건너뜀
  if grep -qF "$base" "$INDEX"; then
    continue
  fi
  topic="$(strip_topic "${base%.pdf}")"
  link_path="$(echo "$SEM/$base" | sed 's/ /%20/g')"   # 공백 → %20 (마크다운 링크 깨짐 방지)
  new_rows+="| $topic | $base | $SEM | [링크]($link_path) |"$'\n'
  echo "  ➕ INDEX 추가: $base"
done

if [ -n "$new_rows" ]; then
  # 앵커 줄 앞에 새 행 삽입 (임시파일 방식, 안전)
  tmp="$(mktemp)"
  while IFS= read -r line; do
    if [[ "$line" == *"$ANCHOR"* ]]; then
      printf '%s' "$new_rows"
    fi
    printf '%s\n' "$line"
  done < "$INDEX" > "$tmp"
  mv "$tmp" "$INDEX"
fi

# ---- 3. git commit + push ----
cd "$REPO_DIR"
if [ -z "$(git status --porcelain)" ]; then
  echo "✅ 변경사항 없음. 종료."
  exit 0
fi

git add .
git -c core.quotepath=false commit -q -m "sync: $SEM 자료 업데이트"
git push -q origin main

# 완료 URL: origin 주소에서 자동 도출 (계정/조직 바뀌어도 정확)
remote="$(git remote get-url origin 2>/dev/null | sed -E 's#git@github.com:#https://github.com/#; s#\.git$##')"
if [ -n "$remote" ]; then
  echo "🚀 완료 → $remote/tree/main/$SEM"
else
  echo "🚀 완료 (push 성공)"
fi
