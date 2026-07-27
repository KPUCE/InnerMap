-- 슬라이스 #7 개발 시드 — 한국공학대학교 본교 건물 19건 + 별칭
--
-- 좌표 출처: OpenStreetMap contributors, ODbL (© OpenStreetMap contributors)
--            Overpass API 조회 2026-07-26. 원본 기록: docs/slice-7/seed-buildings.md
-- 별칭 출처: 저자 확인(author_confirmed) — OSM에는 통칭이 없음
-- 검색 대상 제외: 시흥종합버스터미널, 609(아파트) (구분=주변)
-- 이름 변경: "제2기숙사 (TIP)" → 표시명 TIP (osm_name에 원본 보존)
--
-- 재실행 가능하도록 초기화 후 삽입(개발용).

TRUNCATE building_alias, building RESTART IDENTITY CASCADE;

INSERT INTO building (name, lat, lng, category, status, osm_name, source) VALUES
  ('공학관A동',      37.340429, 126.732890, 'campus', 'published', '공학관A동',       'OSM(ODbL)'),
  ('공학관B동',      37.340353, 126.733302, 'campus', 'published', '공학관B동',       'OSM(ODbL)'),
  ('공학관C동',      37.340009, 126.733987, 'campus', 'published', '공학관C동',       'OSM(ODbL)'),
  ('공학관D동',      37.339689, 126.734144, 'campus', 'published', '공학관D동',       'OSM(ODbL)'),
  ('공학관E동',      37.339713, 126.735044, 'campus', 'published', '공학관E동',       'OSM(ODbL)'),
  ('공학관G동',      37.340264, 126.734741, 'campus', 'published', '공학관G동',       'OSM(ODbL)'),
  ('공학관P동',      37.339414, 126.735535, 'campus', 'published', '공학관P동',       'OSM(ODbL)'),
  ('창조A관',        37.339128, 126.735897, 'campus', 'published', '창조A관',         'OSM(ODbL)'),
  ('창조B관',        37.338811, 126.736414, 'campus', 'published', '창조B관',         'OSM(ODbL)'),
  ('창조C관',        37.339339, 126.736505, 'campus', 'published', '창조C관',         'OSM(ODbL)'),
  ('대학본부',       37.338646, 126.735821, 'campus', 'published', '대학본부',        'OSM(ODbL)'),
  ('행정동',         37.339755, 126.733523, 'campus', 'published', '행정동',          'OSM(ODbL)'),
  ('종합교육관',     37.340667, 126.734094, 'campus', 'published', '종합교육관',      'OSM(ODbL)'),
  ('창업보육센터',   37.339126, 126.735314, 'campus', 'published', '창업보육센터',    'OSM(ODbL)'),
  ('산학융합본부',   37.338704, 126.734550, 'campus', 'published', '산학융합본부',    'OSM(ODbL)'),
  ('시흥비즈니스센터', 37.340004, 126.732361, 'campus', 'published', '시흥비즈니스센터', 'OSM(ODbL)'),
  ('체육관',         37.341060, 126.733356, 'campus', 'published', '체육관',          'OSM(ODbL)'),
  ('제1기숙사',      37.341772, 126.732341, 'campus', 'published', '제1기숙사',       'OSM(ODbL)'),
  ('TIP',           37.341316, 126.732924, 'campus', 'published', '제2기숙사 (TIP)',  'OSM(ODbL)');

INSERT INTO building_alias (building_id, alias, source)
SELECT b.id, v.alias, 'author_confirmed'
FROM building b
JOIN (VALUES
  ('공학관A동', 'A동'),
  ('공학관B동', 'B동'),
  ('공학관C동', 'C동'),
  ('공학관D동', 'D동'),
  ('공학관E동', 'E동'),
  ('공학관G동', 'G동'),
  ('공학관P동', 'P동'),
  ('대학본부', '본부'),
  ('행정동', '행정관'),
  ('종합교육관', '도서관'),
  ('창업보육센터', '보육센터'),
  ('산학융합본부', '산학융합관'),
  ('시흥비즈니스센터', '비즈니스센터'),
  ('체육관', '실내체육관'),
  ('제1기숙사', '기숙사'),
  ('TIP', '티아이피')
) AS v(name, alias) ON v.name = b.name;
