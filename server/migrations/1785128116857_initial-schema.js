/* 슬라이스 #7 초기 스키마 — building, building_alias + pg_trgm GIN (ADR-007)
 * 저장소는 CJS(package.json에 type:module 없음, 기존 테스트가 require 사용)이므로 CJS로 작성. */

exports.shorthands = undefined;

exports.up = (pgm) => {
  pgm.createExtension('pg_trgm', { ifNotExists: true });

  pgm.createTable('building', {
    id: { type: 'bigserial', primaryKey: true },
    name: { type: 'text', notNull: true },
    lat: { type: 'double precision', notNull: true },
    lng: { type: 'double precision', notNull: true },
    category: { type: 'text', notNull: true, default: 'campus' },
    status: { type: 'text', notNull: true, default: 'draft' },
    osm_name: { type: 'text' },
    source: { type: 'text', notNull: true },
    created_at: { type: 'timestamptz', notNull: true, default: pgm.func('now()') },
    updated_at: { type: 'timestamptz', notNull: true, default: pgm.func('now()') },
  });
  // R-12b: 게시 상태만 노출. 상태 3값 강제(전이 이력 테이블은 범위 밖 — 관리자 웹 #11)
  pgm.addConstraint('building', 'building_status_check',
    "CHECK (status IN ('draft','review','published'))");

  pgm.createTable('building_alias', {
    id: { type: 'bigserial', primaryKey: true },
    building_id: { type: 'bigint', notNull: true, references: 'building', onDelete: 'CASCADE' },
    alias: { type: 'text', notNull: true },
    source: { type: 'text', notNull: true, default: 'author_confirmed' },
    created_at: { type: 'timestamptz', notNull: true, default: pgm.func('now()') },
  });
  pgm.addConstraint('building_alias', 'building_alias_unique', { unique: ['building_id', 'alias'] });

  // 부분일치(ILIKE '%q%')는 선행 와일드카드라 btree가 안 먹음 → trigram GIN (ADR-007)
  pgm.sql('CREATE INDEX building_name_trgm ON building USING gin (name gin_trgm_ops);');
  pgm.sql('CREATE INDEX building_alias_trgm ON building_alias USING gin (alias gin_trgm_ops);');

  pgm.createIndex('building', 'status');
  pgm.createIndex('building_alias', 'building_id');
};

exports.down = (pgm) => {
  pgm.dropTable('building_alias');
  pgm.dropTable('building');
  pgm.dropExtension('pg_trgm', { ifExists: true });
};
