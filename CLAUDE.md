# InnerMap 팀 규약 (AI 규약 파일)

## 스택 (ADR-002)
- iOS 앱: SwiftUI, 음성은 OS 내장(VoiceOver·AVSpeechSynthesizer)
- API 서버: Node.js 20 + Express, PostgreSQL
- 관리자 웹: React
- 지도 데이터: 공공데이터(도로명주소 건물 API·V-World) 주 + 네이버 지도 보조 (ADR-003)

## 구조
모노레포(ADR-004): /ios /server /admin-web /batch /docs. 변경 경로에 따라 CI 2계열이 선택 실행된다.

## 컨벤션
- 방위 표현은 항상 시계 방위(클록 페이스)로 통일한다 — "3시 방향", 도(°) 사용 금지
- 거리 기본 단위는 미터
- API 경로는 kebab-case 복수형: /api/buildings, /api/buildings/{id}/aliases
- 커밋: '동사: 요약 (#이슈번호)' · 브랜치: feature/{이슈번호}-{요약}
- 모든 사용자 안내 텍스트는 접근성 알림으로 전달한다(R-10)

## 금칙
- 좌표 수동 입력 금지 — 좌표는 공공데이터에서만 온다
- 시크릿·API 키를 코드·커밋에 포함 금지 — 환경변수·Actions 시크릿만
- '게시' 상태가 아닌 건물을 검색·브리핑에 노출 금지(R-12b)
- 마이그레이션 파일 직접 수정 금지 — 새 파일로 추가
- SRS에 없는 기능을 임의 추가 금지 — R-번호 없는 작업은 이슈로 만들 수 없다

## 참조
docs/ 아래 SRS v2, 시스템 설계 문서, ADR 001~004, Product Backlog
