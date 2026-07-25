# Sprint 0 셋업 런북 (실행 순서 엄수)

전제: gh CLI 로그인(gh auth login), KPUCE/InnerMap이 비어 있음(README 초기화만).

① 파일 투입 — 이 묶음 전체를 저장소 루트에 커밋·푸시한다(아직 보호 규칙 전이므로 main 직접 푸시 가능).
   git clone https://github.com/KPUCE/InnerMap && (묶음 복사) && git add -A && git commit -m "추가: Sprint 0 저장소 골격" && git push

② 백로그 등록 — bash innermap_setup.sh
   라벨 8종·마일스톤 Sprint 0~3·이슈 #1~#13(+스토리 #14~)을 순서대로 등록한다.
   주의: 실행 전 이슈·PR이 하나라도 있으면 번호 정합이 깨져 스크립트가 중단된다.

③ 보드 구성(UI) — Projects 새 보드: 컬럼 Backlog/Sprint Backlog/In Progress/In Review/Done,
   Workflows에서 자동화 3개(Item added→Backlog, PR 열림→In Review, 머지·닫힘→Done), 저장소 이슈 전체 추가.

④ 브랜치 보호(UI) — Settings→Branches→main: PR 필수, 승인 1인, 상태 체크 필수에 "gate" 등록, 직접 푸시 금지.
   순서 주의: ①의 직접 푸시가 끝난 뒤에 켠다.

⑤ 리허설(실습 8 ⑤) — 더미 이슈 → feature 브랜치 → 일부러 실패하는 테스트 → PR(잠김 캡처) → 수정 → 머지 → 보드 Done 확인.
   상세: docs/pipeline-verification.md
