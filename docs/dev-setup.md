# 개발 환경 설치 기록 (macOS · Apple Silicon)

이 문서는 슬라이스 #7/#8 작업을 위해 맥북에 개발 환경을 세운 **실제 과정**을 그대로 남긴 것이다.
학생이 따라 할 수 있도록 실행한 명령과 결과를 적는다. 값은 이 저장소에서 실제로 실행해 얻은 것이다.

## 0. 시작 상태

- 기기: Apple Silicon (arm64), macOS 26.5.2 (25F84)
- 이미 있던 것: Xcode 16.2 + Command Line Tools(git 2.39.5), iOS 시뮬레이터(iPhone 16 계열·SE 3세대)
- 없던 것: **Homebrew, Node, npm, PostgreSQL, gh** — 사실상 백지 상태

## 1. Homebrew 설치 — 저자가 직접 실행

Homebrew 부트스트랩은 관리자 암호(sudo)를 요구한다. AI 세션은 암호를 입력할 수 없으므로 **이 한 단계는 사람이 자기 터미널에서 실행한다.**

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

설치 결과: Homebrew 6.0.12.

> 함정: 설치 프로그램은 PATH 등록 줄을 자동으로 넣어주지 않는다. 안내만 출력하고 끝난다.
> 이번에도 `~/.zprofile`에 shellenv 줄이 빠져 있어, 새 터미널에서 `brew`/`node`를 못 찾는 상태가 잠깐 생겼다(아래 3절에서 바로잡음).

## 2. Node · PostgreSQL · gh 설치

Homebrew가 깔린 뒤부터는 sudo가 필요 없다(그것이 Homebrew의 목적). 아래는 AI 세션이 실행했다.

```bash
brew install node postgresql@16 gh
```

설치된 버전(실제 확인값):

| 도구 | 버전 |
|---|---|
| node | v26.5.0 |
| npm | 11.17.0 |
| psql (PostgreSQL) | 16.14 |
| gh | 2.96.0 |

> ⚠️ **Node 버전 차이**: 로컬은 Node 26, 그러나 CI(`.github/workflows/merge-gate.yml`의 `server-test`)는 **Node 20**으로 고정돼 있다.
> 우리 코드(Express·pg·`node:test`)는 20~26에서 동일하게 동작하는 범위만 쓴다. 26 전용 기능을 쓰면 CI에서 깨질 수 있으니 주의.
> 정확한 재현이 필요하면 나중에 `node@20`을 별도로 설치해 맞출 수 있다(현재는 보류).

## 3. PATH 설정 (`~/.zprofile`)

`postgresql@16`은 **keg-only**라 `/opt/homebrew/bin`에 자동 링크되지 않는다. 직접 PATH에 넣어야 `psql`이 잡힌다.
Homebrew shellenv 줄과 함께 `~/.zprofile`을 아래와 같이 정리했다.

```sh
# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"
# PostgreSQL 16 (keg-only — 자동 링크되지 않아 직접 PATH 등록)
export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
```

새 로그인 셸에서 확인:

```
brew: /opt/homebrew/bin/brew
node: v26.5.0
npm:  11.17.0
psql: psql (PostgreSQL) 16.14 (Homebrew)
gh:   gh version 2.96.0
```

## 4. PostgreSQL 기동과 검증

사용자 서비스로 기동한다(sudo 불필요).

```bash
brew services start postgresql@16
```

검증:

```bash
pg_isready            # → /tmp:5432 - accepting connections
psql -l               # postgres/template0/template1, 소유주 gijeon
```

Homebrew PostgreSQL은 첫 기동 때 **현재 macOS 사용자(gijeon)를 슈퍼유저**로 하는 클러스터를 만든다.
기본 DB로 `postgres`가 있고, 사용자 이름과 같은 DB는 아직 없다. 슬라이스용 개발 DB는 3단계(마이그레이션·시드)에서 만든다.

## 5. 남은 작업 / 알아둘 것

- [ ] `gh auth login` — 아직 로그인 안 됨. 이슈 조회는 지금까지 공개 GitHub API(curl)로 우회했다. PR 생성 단계에서 로그인 필요.
- [ ] 슬라이스용 개발 DB 생성은 3단계에서.
- 이 문서는 아직 커밋하지 않았다(main 직접 푸시 금지). 슬라이스 브랜치/PR에 포함한다.
