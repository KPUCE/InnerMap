# InnerMap — 시각장애인을 위한 공간 학습 도우미

처음 가는 낯선 지역·시설에서 스마트폰만으로 공간의 인지 지도(cognitive map)를 만들도록 돕는 학습 도구입니다.
실시간 내비게이션이 아닙니다 — 폰 위쪽을 12시로 삼는 클록 페이스 기준, 반경 50·100·150m 밴드의 건물을 시계방향으로 음성 브리핑합니다.

## 저장소 구조 (모노레포 — ADR-004)

| 경로 | 내용 |
|---|---|
| /ios | iOS 앱 (SwiftUI) |
| /server | API 서버 (Node.js + Express, PostgreSQL) |
| /admin-web | 관리자 웹 (React) — 수집→검수→게시 |
| /batch | 공공데이터 수집 배치 |
| /docs | SRS·설계 문서·ADR 체인·팀 규약 |

## 협업 규칙 (요약)

- 브랜치: `feature/{이슈번호}-{요약}` · 버그 `fix/{이슈번호}-{요약}` — 예: `feature/7-search-api`
- 커밋: `동사: 요약 (#이슈번호)` — 예: `추가: 건물 검색 API — 부분 일치+별칭 (#7)`
- 머지: Squash — 이슈 하나 = main 커밋 하나
- main 직접 푸시 금지 · gate 체크 통과 · 리뷰 1인 승인 필수
- 이슈 없는 작업 금지 · In Progress 1인 1건

## 문서

- 요구사항: docs/InnerMap_SRS_v2.md (원본 docx는 팀 드라이브)
- 설계: docs/InnerMap_시스템설계문서.md · ADR: docs/adr/
- 백로그·로드맵: docs/InnerMap_ProductBacklog.md
- 파이프라인 이해 검증: docs/pipeline-verification.md
