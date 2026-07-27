# 07 CI 실행 기록 (ⅩⅢ장 재료)

## PR #29 — 추가: 건물 검색 API — 부분 일치+별칭 (#7)

- PR: https://github.com/KPUCE/InnerMap/pull/29
- 실행: https://github.com/KPUCE/InnerMap/actions/runs/30239220743 (merge-gate, pull_request, 2026-07-27)

| 잡 | 결과 | 시간 | 비고 |
|---|---|---|---|
| changes | ✅ pass | 4s | server=true, ios=false 감지 |
| pr-size | ✅ pass | 2s | **+1283줄(package-lock) 초과였으나 `size:exempt` 라벨로 PO 승인 예외 통로 작동** — 게이트 설계(Ⅷ장)의 예외 경로가 실전에서 처음 쓰임 |
| server-test | ✅ pass | 33s | **postgres:16 서비스 첫 가동** — npm ci → migrate up → seed → `node --test` 17/17. 이 PR에서 추가한 A안 구성이 CI에서 실제로 동작 |
| ios-build | ⏭️ skipped | — | ios/** 변경 없음 — 모노레포 경로 필터가 의도대로 '건너뜀' 처리, gate는 이를 '해당 없음'으로 취급 |
| secret-scan | ✅ pass | 10s | gitleaks, 전체 이력 |
| gate | ✅ pass | 4s | 종합 판정 — 브랜치 보호 필수 체크 |

## 관찰

- 러너 어노테이션: `actions/checkout@v4`·`dorny/paths-filter@v3`·`gitleaks-action@v2`가 Node 20 타깃인데 러너가 Node 24로 강제 실행 중이라는 deprecation 경고. 동작엔 지장 없으나 액션 버전 올리기가 후속 과제로 남음(이슈로 만들려면 R-번호 없는 인프라 작업이라 parked 또는 저자 판단 필요).
- server-test 33초 중 대부분은 postgres 서비스 헬스체크·npm ci. DB 붙은 게이트치고 충분히 빠름.
