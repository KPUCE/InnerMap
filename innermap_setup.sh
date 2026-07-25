#!/usr/bin/env bash
# InnerMap 백로그 등록 스크립트 (Ⅷ장 Sprint 0 — 실습 8 ③)
# 사용: gh auth login 상태의 로컬에서  bash innermap_setup.sh
# 전제: KPUCE/InnerMap 저장소에 이슈·PR이 하나도 없어야 함(이슈 번호 #1~#13 정합)
set -euo pipefail
REPO="KPUCE/InnerMap"

echo "== 0. 저장소 확인 =="
gh repo view "$REPO" --json name,visibility -q '.name + " (" + .visibility + ")"'

OPEN_COUNT=$(gh issue list --repo "$REPO" --state all --limit 1 --json number -q 'length')
if [ "$OPEN_COUNT" != "0" ]; then
  echo "오류: 저장소에 이미 이슈가 있습니다. 이슈 번호 정합(#1~#13)이 깨지므로 중단합니다."; exit 1
fi

echo "== 1. 라벨 =="
gh label create "epic:E0" --repo "$REPO" -c "6f42c1" -d "기반 구축(기술 에픽)" --force
gh label create "epic:E1" --repo "$REPO" -c "1d76db" -d "건물 검색·조회" --force
gh label create "epic:E2" --repo "$REPO" -c "0e8a16" -d "현장 브리핑(관통 기능)" --force
gh label create "epic:E3" --repo "$REPO" -c "d93f0b" -d "건물 데이터 관리" --force
gh label create "epic:E4" --repo "$REPO" -c "fbca04" -d "사전 학습" --force
gh label create "epic:E5" --repo "$REPO" -c "c2e0c6" -d "탐색 보조·설정" --force
gh label create "type:story" --repo "$REPO" -c "bfdadc" -d "스토리 수준(AC 거칠게)" --force
gh label create "type:issue" --repo "$REPO" -c "0052cc" -d "Ready 이슈(AC 완비)" --force

echo "== 2. 마일스톤 (로드맵 v1 기준) =="
ms() { gh api "repos/$REPO/milestones" -f title="$1" -f due_on="$2T09:00:00Z" -f description="$3" -q .number; }
MS0_NUMS=$(ms "Sprint 0" "2027-01-15" "기반 구축 — 저장소·보드·파이프라인")
MS1_NUMS=$(ms "Sprint 1" "2027-01-29" "데이터 파이프라인 + 검색 착수")
MS2_NUMS=$(ms "Sprint 2" "2027-02-12" "검색 흐름 완성 — 첫 E2E 시연")
MS3_NUMS=$(ms "Sprint 3" "2027-02-26" "현장 브리핑 — 핵심 기능 완성")

echo "== 3. 이슈 등록 (#1~#13 순서 고정) =="
mk() {
  if [ -n "$3" ]; then
    gh issue create --repo "$REPO" --title "$1" --label "$2" --milestone "$3" --body "$4" >/dev/null
  else
    gh issue create --repo "$REPO" --title "$1" --label "$2" --body "$4" >/dev/null
  fi
  echo "  등록: $1"
}

mk "프로젝트 저장소 개설과 기본 규칙" "epic:E0,type:issue" "Sprint 0" "$(printf '## 작업\n모노레포 골격(/ios /server /admin-web /batch /docs)과 브랜치·머지 기본 규칙.\n\n## 수용 기준 (AC)\n- [ ] 디렉터리 골격과 README 배치\n- [ ] main 보호: 직접 푸시 금지, PR 필수\n- [ ] CLAUDE.md 규약 파일 배치\n\n## 추적성\nADR-001 · ADR-004')"
mk "작업 보드 구성" "epic:E0,type:issue" "Sprint 0" "$(printf '## 작업\nProjects 보드 5컬럼과 자동화.\n\n## 수용 기준 (AC)\n- [ ] 컬럼: Backlog / Sprint Backlog / In Progress / In Review / Done\n- [ ] 자동화: 할당→In Progress, PR→In Review, 머지→Done\n- [ ] WIP 제한 1인 1건 합의 기록\n\n## 추적성\nⅦ장 백로그')"
mk "자동 검사 2계열(머지 게이트) 구성" "epic:E0,type:issue" "Sprint 0" "$(printf '## 작업\n파이프라인 ①: PR 검증. 경로 필터로 iOS 빌드 / 서버·관리자웹 테스트 2계열.\n\n## 수용 기준 (AC)\n- [ ] /ios 변경 시 iOS 빌드 검사 실행\n- [ ] /server·/admin-web·/batch 변경 시 테스트 실행\n- [ ] 변경 300줄 초과 시 실패 처리\n- [ ] 상태 체크가 브랜치 보호에 연결되어 실패 시 머지 잠김\n\n## 추적성\nADR-001 · ADR-002 · ADR-004')"
mk "완료의 정의(DoD) 명문화" "epic:E0,type:issue" "Sprint 0" "$(printf '## 작업\nDoD 6항목과 강제 주체를 PR 템플릿·문서로 명문화.\n\n## 수용 기준 (AC)\n- [ ] 접근성 자동 검사 위반 0건 항목 포함(N-02)\n- [ ] 안내 텍스트 접근성 알림 전달 항목 포함(R-10)\n- [ ] 핵심 흐름 VoiceOver 완주 항목 포함(N-01)\n- [ ] PR 템플릿에 DoD 체크리스트 반영\n\n## 추적성\nN-01 · N-02 · R-10')"
mk "외부 API 키 발급·보관" "epic:E0,type:issue" "Sprint 0" "$(printf '## 작업\n공공데이터포털 건물 API·V-World·네이버클라우드 지도 키 발급.\n\n## 수용 기준 (AC)\n- [ ] 3종 키 발급 완료\n- [ ] 키는 서버 환경변수·Actions 시크릿으로만 보관\n- [ ] 클라이언트 코드에 키 미포함 확인\n\n## 추적성\nR-11 · ADR-003 · N-06 (#10의 외부 의존 선행 해소)')"
mk "개발 환경 표준" "epic:E0,type:issue" "Sprint 0" "$(printf '## 작업\n버전 합의와 로컬 셋업.\n\n## 수용 기준 (AC)\n- [ ] Xcode·Node.js·PostgreSQL 버전 기록\n- [ ] 로컬 DB 셋업 스크립트\n- [ ] .env 규칙 — 시크릿 커밋 금지\n\n## 추적성\nADR-002 · N-06')"
mk "건물 검색 API — 부분 일치+별칭" "epic:E1,type:issue" "Sprint 1" "$(printf '## 스토리\n시각장애 학생으로서 이름 일부·별칭으로 건물을 찾고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 부분 일치와 별칭 일치의 합집합 검색\n- [ ] 게시 상태 건물만 노출\n- [ ] 현재 위치 기준 가까운 순 최대 10건\n- [ ] 0건이면 빈 결과+사유 코드\n\n## 추적성\nR-01/02 · R-01b · R-12b · ADR-002')"
mk "iOS 검색 화면 — VoiceOver 완주" "epic:E1,type:issue" "Sprint 2" "$(printf '## 스토리\n시각장애 학생으로서 화면을 보지 않고 검색을 끝까지 쓰고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 검색 입력·결과 목록이 접근성 요소로 노출\n- [ ] 0건 시 대안 안내를 접근성 알림으로 전달\n- [ ] 검색 흐름 VoiceOver만으로 완주(N-01·N-02)\n\n## 추적성\nR-04 · R-10')"
mk "건물 상세 안내 — 방위·거리" "epic:E1,type:issue" "Sprint 2" "$(printf '## 스토리\n검색 결과에서 건물을 골라 방위·거리를 듣고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 공식명·별칭·시계 방위·거리 안내\n- [ ] 방위는 클록 페이스(12시=폰 위쪽) 환산\n- [ ] 거리 기본 단위 미터\n- [ ] 접근성 알림으로 전달. 방위 검증은 단위 테스트 수준(현장 측정은 N-04, Sprint 4)\n\n## 추적성\nR-03 · N-04')"
mk "공공데이터 수집 배치" "epic:E3,type:issue" "Sprint 1" "$(printf '## 스토리\n관리자로서 대상 지역 건물 데이터를 자동으로 확보하고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 도로명주소 건물 API+V-World에서 건물명·좌표 수집\n- [ ] 수집 상태로 저장\n- [ ] 새벽 시간대 스케줄 실행(RT4)\n\n## 추적성\nR-11 · ADR-003')"
mk "검수·게시 상태 전이(관리자 웹)" "epic:E3,type:issue" "Sprint 1" "$(printf '## 스토리\n검수자로서 수집 데이터를 확인해 게시를 결정하고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 승인 시에만 게시 전이(수집→검수→게시)\n- [ ] 반려 시 수집으로 회송\n- [ ] 검색·브리핑 쿼리는 게시 상태만 노출\n\n## 추적성\nR-12a · R-12b')"
mk "별칭 등록·수정" "epic:E3,type:issue" "Sprint 2" "$(printf '## 스토리\n검수자로서 통용 별칭을 등록해 검색 적중률을 높이고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 별칭 등록·수정·삭제\n- [ ] 다음 검색부터 즉시 반영\n- [ ] 별칭도 게시 상태 규칙을 따름\n\n## 추적성\nR-13')"
mk "관리 API 관리자 인증" "epic:E3,type:issue" "Sprint 1" "$(printf '## 스토리\n운영자로서 관리 기능이 인증된 요청만 처리하게 하고 싶다.\n\n## 수용 기준 (AC)\n- [ ] 수집·검수·게시·별칭 관리 API는 관리자 인증 필수\n- [ ] LLM 프록시 경로 포함\n- [ ] 미인증 요청 거부 로그\n\n## 추적성\nR-22 (#11에서 분할)')"

echo "== 4. Sprint 3·백로그 스토리(번호 #14 이후 자동) =="
mk "클록 페이스 브리핑 정렬 엔진" "epic:E2,type:story" "Sprint 3" "$(printf '## 스토리\n12시 기준 시계방향 정렬, 밴드당 최대 5개+외 N개.\n\n## 수용 기준 (AC) — 거칠게, 정제 대기\n- [ ] 정렬·상한·외 N개 규칙\n\n## 추적성\nR-05a · R-05b · R-06')"
mk "점진적 공개 UI — 다음 반경·다시 듣기" "epic:E2,type:story" "Sprint 3" "$(printf '## 스토리\n버튼 2개로 다음 밴드·재청취.\n\n## 수용 기준 (AC) — 거칠게, 정제 대기\n- [ ] 버튼 2개 · 0건 안내\n\n## 추적성\nR-07 · R-08 · R-08b')"
mk "센서 안전장치 — 보정·위치 신호 안내" "epic:E2,type:story" "Sprint 3" "$(printf '## 수용 기준 (AC) — 거칠게, 정제 대기\n- [ ] 나침반 보정 안내 · 위치 신호 저하 안내\n\n## 추적성\nR-09 · R-09b')"
mk "기기 캐시 지속(오프라인 모드 아님)" "epic:E3,type:story" "Sprint 3" "$(printf '## 수용 기준 (AC) — 거칠게, 정제 대기\n- [ ] 게시 건물·별칭 캐시, 재시작 후 유지\n\n## 추적성\nR-12c')"
mk "LLM 브리핑 문안 생성(검수 대기 저장)" "epic:E3,type:story" "" "$(printf '## 추적성\nR-14 · R-14b — 상세는 ⅩⅤ장, 마일스톤 미배정')"
mk "실패 유형 익명 수집·주간 실패율" "epic:E2,type:story" "" "$(printf '## 추적성\nN-07 — 마일스톤 미배정')"
mk "방위 오차 현장 측정 프로토콜 설계" "epic:E2,type:story" "" "$(printf '## 추적성\nN-04 — SRS 유보 항목의 해제, 마일스톤 미배정')"
mk "사전 학습 — 기준점 가상 위치·동일 문법 브리핑" "epic:E4,type:story" "" "$(printf '## 추적성\nR-16 · R-17 · R-17b — 에픽 덩어리')"
mk "탐색 보조·설정 — 포인팅·터치 탐색·거리 단위" "epic:E5,type:story" "" "$(printf '## 추적성\nR-18 · R-19 · R-20 — 에픽 덩어리')"
mk "정기 재수집" "epic:E3,type:story" "" "$(printf '## 추적성\nR-15 — 에픽 덩어리')"

echo "== 완료 =="
echo "다음 수동 작업: Projects 보드 생성·컬럼·자동화(실습 8 ③, UI 권장), 브랜치 보호 규칙(Settings → Branches)"
