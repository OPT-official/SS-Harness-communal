# SS-Harness-communal

> **OPT 2026 Summer Season · 8월 학회 공동 하네스**
> 목표 한 줄: `git clone` → 몇 분 안에 세팅 → **누구나 바로 사용.**

---

## 🎯 이 레포가 완성되면

OPT 학회원 누구든 (개발 트랙 아니어도):

```bash
git clone https://github.com/OPT-official/SS-Harness-communal.git
cd SS-Harness-communal
# → docs/usage-guide.md 따라 몇 분 세팅 → Claude Code에서 바로 사용
```

VS Code + Claude Code(또는 Codex) 기준. 추가 학습 없이 쓸 수 있어야 함.

## 📂 폴더 구조

```
.claude/     공동 settings.json · 공유 hooks · 공유 skills
src/         세팅 스크립트, 공용 도구
docs/        사용법 · 트러블슈팅 · 커스터마이징 가이드
```

## 🔨 만드는 과정 (해커톤식)

```
1. 후보 수집    SS-Harness-private 산출물 중 팀에 유용한 것
                → integration-task Issue로 제안
2. 통합         모임에서 투표 → 담당 배분 → 그 자리에서 작업
                충돌하는 설정은 그 자리에서 결정 (미루지 않기)
3. 검증         서로 clone해서 테스트 → 버그는 Issue로
4. 문서화       docs/ 완성 — 아래 완성 기준 통과할 때까지
```

## ✅ 완성 기준 (Definition of Done)

> **개발 트랙이 아닌 신규 학회원이 docs만 보고
> clone부터 실사용까지 혼자 도달할 수 있는가?**

이거 하나로 판단. 안 되면 미완성.

---

## 🇬🇧 English (TL;DR)

Shared org-wide Claude Code harness (August). Consolidates the best pieces
from SS-Harness-private via hackathon-style integration. Done means: a new
club member outside the dev track can go from clone to real usage alone,
using only the docs.
