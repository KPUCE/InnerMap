/* #7 건물 검색 API — 명세: docs/slice-7/design.md, 결정: ADR-007
 * 매칭: name 부분일치 ∪ alias 부분일치(pg_trgm) → published만(R-12b) → 하버사인 거리순 → 최대 10건 */
const express = require('express');
const { Pool } = require('pg');

// 하버사인 식(SQL) — ADR-007: PostGIS 없이 lat/lng 컬럼으로 계산
const SEARCH_SQL = `
  SELECT b.id, b.name,
         CASE WHEN b.name ILIKE $1 THEN NULL ELSE ma.alias END AS matched_alias,
         6371000 * 2 * asin(sqrt(
           power(sin(radians(b.lat - $2) / 2), 2) +
           cos(radians($2)) * cos(radians(b.lat)) *
           power(sin(radians(b.lng - $3) / 2), 2)
         )) AS distance_m
  FROM building b
  LEFT JOIN LATERAL (
    SELECT a.alias FROM building_alias a
    WHERE a.building_id = b.id AND a.alias ILIKE $1
    ORDER BY a.alias LIMIT 1
  ) ma ON true
  WHERE b.status = 'published'
    AND (b.name ILIKE $1 OR ma.alias IS NOT NULL)
  ORDER BY distance_m ASC
  LIMIT $4`;

function badRequest(res, errorCode, message) {
  return res.status(400).json({ error_code: errorCode, message });
}

function createApp() {
  // allowExitOnIdle: 테스트 종료 시 유휴 커넥션이 프로세스를 붙잡지 않도록
  const pool = new Pool({ connectionString: process.env.DATABASE_URL, allowExitOnIdle: true });
  const app = express();

  app.get('/api/buildings/search', async (req, res) => {
    const { q, lat, lng, limit } = req.query;

    // 빈·공백 질의 → 400 (1자는 허용 — 경계 케이스, design.md)
    if (typeof q !== 'string' || q.trim().length === 0) {
      return badRequest(res, 'EMPTY_QUERY', '검색어가 비어 있습니다.');
    }
    const latNum = Number(lat);
    const lngNum = Number(lng);
    if (lat === undefined || lng === undefined || lat === '' || lng === '' ||
        !Number.isFinite(latNum) || !Number.isFinite(lngNum) ||
        latNum < -90 || latNum > 90 || lngNum < -180 || lngNum > 180) {
      return badRequest(res, 'INVALID_LOCATION', '현재 위치(lat, lng)가 없거나 잘못되었습니다.');
    }
    let limitNum = 10;
    if (limit !== undefined) {
      limitNum = Number(limit);
      if (!Number.isInteger(limitNum) || limitNum < 1) {
        return badRequest(res, 'INVALID_PARAM', 'limit은 1 이상의 정수여야 합니다.');
      }
      if (limitNum > 10) limitNum = 10; // AC: 최대 10건 — 초과는 절삭
    }

    try {
      const pattern = `%${q.trim()}%`;
      const { rows } = await pool.query(SEARCH_SQL, [pattern, latNum, lngNum, limitNum]);
      const results = rows.map((r) => ({
        id: Number(r.id),
        name: r.name,
        matched_alias: r.matched_alias,
        distance_m: Math.round(r.distance_m * 10) / 10,
      }));
      res.json({
        count: results.length,
        results,
        reason_code: results.length === 0 ? 'NO_MATCH' : null, // AC: 0건이면 사유 코드
      });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error_code: 'INTERNAL', message: '서버 오류가 발생했습니다.' });
    }
  });

  return app;
}

module.exports = { createApp };
