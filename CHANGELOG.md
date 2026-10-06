# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 (2026-10-06)


### Features

* add 12 new evals covering uncovered commands and shell features ([2c21f75](https://github.com/gethealthkey/just_bash/commit/2c21f757a9307c2cac494f4e0fa736698af5915f))
* add context option to justbash struct for custom commands ([#34](https://github.com/gethealthkey/just_bash/issues/34)) ([8824fd9](https://github.com/gethealthkey/just_bash/commit/8824fd96db0863f2c7d07dc2925df6a280be4281))
* add custom command eval with KV store ([840ba00](https://github.com/gethealthkey/just_bash/commit/840ba00db53fc8b4628b203568e75c2b06af943a))
* add eval system and fix 5 bugs exposed by LLM agent evals ([39e4637](https://github.com/gethealthkey/just_bash/commit/39e463757092b8732f7523d2f6d86dbeea93ee2d))
* expand evals to 28 tasks and fix 8 additional bugs ([5ba37c5](https://github.com/gethealthkey/just_bash/commit/5ba37c51d723cedf8797505ecf5f132db548795d))
* GNU-compatible grep and a bash/sh child-shell command ([25177bb](https://github.com/gethealthkey/just_bash/commit/25177bba151667f6dcfc4d6e509dcc12d722b7d2))
* GNU-compatible grep and a bash/sh child-shell command ([17cd480](https://github.com/gethealthkey/just_bash/commit/17cd480b3d0fc24c546c48c4a000a546cf0fb626))
* major expansion - 15 new commands, jq overhaul, test infrastructure ([a5efb73](https://github.com/gethealthkey/just_bash/commit/a5efb73bda8409fa59aab1cb9752ace0d4bedeba))
* test infrastructure, new commands, jq overhaul ([13749d2](https://github.com/gethealthkey/just_bash/commit/13749d2aa7c8b752acb3e52b3f9f53a5c1cd98c9))


### Bug Fixes

* 8 AWK bugs, jq -e exit status, declare -A keys, printf redirect parsing ([cb57e64](https://github.com/gethealthkey/just_bash/commit/cb57e646e01de36eb67bb92eedbf79e2e8cf412b))
* add sort, date, uniq, find, misc coverage and fixes ([a68ad8d](https://github.com/gethealthkey/just_bash/commit/a68ad8dac6de8034961c0ad4e0b4094f91c9ef4f))
* ansi-c handling ([9bcd485](https://github.com/gethealthkey/just_bash/commit/9bcd485fdb8c8d7c1ffeb15cd0e2f2380cbd595b))
* capture bash state between exec calls in README example ([09b2039](https://github.com/gethealthkey/just_bash/commit/09b2039fd2940fe8e5db95410317250ee5830d01))
* correct GitHub URLs in CHANGELOG ([a4cf791](https://github.com/gethealthkey/just_bash/commit/a4cf791d4c281529ee795e4b200515e10bbec3dd))
* correct GitHub URLs in CHANGELOG ([5b29c7e](https://github.com/gethealthkey/just_bash/commit/5b29c7e8748afc4cadbb22bd2b8e9893dd9cb431))
* credo issues ([47689d7](https://github.com/gethealthkey/just_bash/commit/47689d73d3544c7550b23df14bbf7d5cd30b70e9))
* credo issues ([e4d6272](https://github.com/gethealthkey/just_bash/commit/e4d62721bbc75f4955f8fa4f35384768db769c77))
* date/sort/uniq/find ([e5385bb](https://github.com/gethealthkey/just_bash/commit/e5385bb6c6318cff84d64b34aceafd8c9d2cc9f1))
* extend test coverage for arrays, functions, globs, wc ([140b1d6](https://github.com/gethealthkey/just_bash/commit/140b1d6d55a39f7c34de504fd5ce6c87b7404a09))
* extend test coverage for arrays, functions, globs, wc ([7497793](https://github.com/gethealthkey/just_bash/commit/749779330eee0895861190152f32374b929525f0))
* heredoc in compound commands, assoc array subscripts, which/type builtins, jq [@tsv](https://github.com/tsv) ([99aab44](https://github.com/gethealthkey/just_bash/commit/99aab442ef02edef740b72c56792ef017724b9e8))
* implement AWK field assignment ($N = value) with $0 reconstruction ([e760cad](https://github.com/gethealthkey/just_bash/commit/e760cad327acd2d7af737dcb79bc5c64a8f82cae))
* implement limitations ([84fc7c7](https://github.com/gethealthkey/just_bash/commit/84fc7c719882277bc38f2a25d64f5b92eba2945a))
* improve sed test coverage and fix parsing issues ([a3b0db6](https://github.com/gethealthkey/just_bash/commit/a3b0db6db8069a98c8ba204b950bb29e6e0145a2))
* improve sed test coverage and fix parsing issues ([433ee3b](https://github.com/gethealthkey/just_bash/commit/433ee3bcd210a1d63d6a598dea1bd8e907eba984))
* improved awk coverage and fixes ([dc23b80](https://github.com/gethealthkey/just_bash/commit/dc23b800fa73f1271b716dd183ac52ea5d647913))
* improved awk coverage and fixes ([42fdd2a](https://github.com/gethealthkey/just_bash/commit/42fdd2a49c792dd124c864b5f9c38792736a9b50))
* jq tests and fix parser issues ([64eafaf](https://github.com/gethealthkey/just_bash/commit/64eafafa7f71e03f4783e9c5a2b91acd149305c2))
* jq tests and fix parser issues ([cef237d](https://github.com/gethealthkey/just_bash/commit/cef237d483bff59b0a748c3c35b36aee05f81c1e))
* math and redirect issues ([06a8aa8](https://github.com/gethealthkey/just_bash/commit/06a8aa86ebb6d79a3dca49776d922e4c96c0bcb5))
* math and redirect issues ([c7de7b7](https://github.com/gethealthkey/just_bash/commit/c7de7b74f8a21d0051d02f1e2b3d23c1f9d19af0))
* read IFS splitting, wc/head/tail multi-file, and improve eval robustness ([7d96af7](https://github.com/gethealthkey/just_bash/commit/7d96af70bc5ee081a6c4f9bf4e688b8fa277849e))
* remove deprecated package-name from release-please workflow ([d1d7ab7](https://github.com/gethealthkey/just_bash/commit/d1d7ab7794c3c022cb49703c1eda3e2b2413fb04))
* replace retired earmark runtime dependency with mdex ([aec5fe3](https://github.com/gethealthkey/just_bash/commit/aec5fe3d44637edbe4197f9c777d4898886e5183))
* **tests:** use variable instead of module attribute for spec tests ([#18](https://github.com/gethealthkey/just_bash/issues/18)) ([f583911](https://github.com/gethealthkey/just_bash/commit/f583911576329333ae17c8174e3a975df81a8ccb))
* various fixes from real-world usage ([34db271](https://github.com/gethealthkey/just_bash/commit/34db2717895ec01bd77d23abd38c540d076f1532))
* various fixes from real-world usage ([e6d3746](https://github.com/gethealthkey/just_bash/commit/e6d3746f9a70232ad6cb432d72967aebe7310a49))

## [0.3.0](https://github.com/elixir-ai-tools/just_bash/compare/v0.2.0...v0.3.0) (2026-04-14)


### Features

* add context option to justbash struct for custom commands ([#34](https://github.com/elixir-ai-tools/just_bash/issues/34)) ([8824fd9](https://github.com/elixir-ai-tools/just_bash/commit/8824fd96db0863f2c7d07dc2925df6a280be4281))
* add xxd/od, curl flags, grep -P, awk crash guard ([#32](https://github.com/elixir-ai-tools/just_bash/issues/32)) ([4afdb3b](https://github.com/elixir-ai-tools/just_bash/commit/4afdb3b))
* add production resource limits and execution stats ([#28](https://github.com/elixir-ai-tools/just_bash/issues/28)) ([9c7a36d](https://github.com/elixir-ai-tools/just_bash/commit/9c7a36d))
* add missing command flags, stdin support, and bash comparison fixtures ([#31](https://github.com/elixir-ai-tools/just_bash/issues/31)) ([67de3b0](https://github.com/elixir-ai-tools/just_bash/commit/67de3b0))
* replace NimbleParsec lexer with hand-written state machine ([#30](https://github.com/elixir-ai-tools/just_bash/issues/30)) ([bc05d36](https://github.com/elixir-ai-tools/just_bash/commit/bc05d36))
* add telemetry instrumentation for script execution ([#29](https://github.com/elixir-ai-tools/just_bash/issues/29)) ([b8cac23](https://github.com/elixir-ai-tools/just_bash/commit/b8cac23))


### Bug Fixes

* jq parser failing to resolve builtin function names to atoms ([144cbe8](https://github.com/elixir-ai-tools/just_bash/commit/144cbe8))

## [0.2.0](https://github.com/elixir-ai-tools/just_bash/compare/v0.1.0...v0.2.0) (2026-03-23)


### Features

* add 12 new evals covering uncovered commands and shell features ([2c21f75](https://github.com/elixir-ai-tools/just_bash/commit/2c21f757a9307c2cac494f4e0fa736698af5915f))
* add custom command eval with KV store ([840ba00](https://github.com/elixir-ai-tools/just_bash/commit/840ba00db53fc8b4628b203568e75c2b06af943a))
* add eval system and fix 5 bugs exposed by LLM agent evals ([39e4637](https://github.com/elixir-ai-tools/just_bash/commit/39e463757092b8732f7523d2f6d86dbeea93ee2d))
* expand evals to 28 tasks and fix 8 additional bugs ([5ba37c5](https://github.com/elixir-ai-tools/just_bash/commit/5ba37c51d723cedf8797505ecf5f132db548795d))
* major expansion - 15 new commands, jq overhaul, test infrastructure ([a5efb73](https://github.com/elixir-ai-tools/just_bash/commit/a5efb73bda8409fa59aab1cb9752ace0d4bedeba))
* test infrastructure, new commands, jq overhaul ([13749d2](https://github.com/elixir-ai-tools/just_bash/commit/13749d2aa7c8b752acb3e52b3f9f53a5c1cd98c9))


### Bug Fixes

* 8 AWK bugs, jq -e exit status, declare -A keys, printf redirect parsing ([cb57e64](https://github.com/elixir-ai-tools/just_bash/commit/cb57e646e01de36eb67bb92eedbf79e2e8cf412b))
* capture bash state between exec calls in README example ([09b2039](https://github.com/elixir-ai-tools/just_bash/commit/09b2039fd2940fe8e5db95410317250ee5830d01))
* correct GitHub URLs in CHANGELOG ([a4cf791](https://github.com/elixir-ai-tools/just_bash/commit/a4cf791d4c281529ee795e4b200515e10bbec3dd))
* correct GitHub URLs in CHANGELOG ([5b29c7e](https://github.com/elixir-ai-tools/just_bash/commit/5b29c7e8748afc4cadbb22bd2b8e9893dd9cb431))
* heredoc in compound commands, assoc array subscripts, which/type builtins, jq [@tsv](https://github.com/tsv) ([99aab44](https://github.com/elixir-ai-tools/just_bash/commit/99aab442ef02edef740b72c56792ef017724b9e8))
* implement AWK field assignment ($N = value) with $0 reconstruction ([e760cad](https://github.com/elixir-ai-tools/just_bash/commit/e760cad327acd2d7af737dcb79bc5c64a8f82cae))
* read IFS splitting, wc/head/tail multi-file, and improve eval robustness ([7d96af7](https://github.com/elixir-ai-tools/just_bash/commit/7d96af70bc5ee081a6c4f9bf4e688b8fa277849e))
* remove deprecated package-name from release-please workflow ([d1d7ab7](https://github.com/elixir-ai-tools/just_bash/commit/d1d7ab7794c3c022cb49703c1eda3e2b2413fb04))
* **tests:** use variable instead of module attribute for spec tests ([#18](https://github.com/elixir-ai-tools/just_bash/issues/18)) ([f583911](https://github.com/elixir-ai-tools/just_bash/commit/f583911576329333ae17c8174e3a975df81a8ccb))

## [Unreleased]

## [0.1.0] - 2026-01-11

### Added

- Initial release
- In-memory virtual filesystem (`JustBash.Fs.InMemoryFs`)
- Bash lexer and recursive descent parser
- Variable expansion: `$VAR`, `${VAR}`, `${VAR:-default}`, `${VAR:=default}`, `${VAR:+alt}`, `${#VAR}`, `${VAR:start:len}`, `${VAR#pattern}`, `${VAR%pattern}`, `${VAR/old/new}`, `${VAR^^}`, `${VAR,,}`
- Command substitution: `$(cmd)` and backticks
- Arithmetic expansion: `$((expr))` with full operator support including `**`, `?:`, hex, binary
- Control flow: `if/elif/else/fi`, `for x in ...; do; done`, `while/until`, `case/esac`
- Logical operators: `&&`, `||`, `!` with short-circuit evaluation
- Pipes with stdin/stdout flow
- Redirections: `>`, `>>`, `2>`, `&>`, `<`, `<<<`, heredocs
- Brace expansion: `{a,b,c}`, `{1..5}`, `{a..z}`
- Arrays: `arr=(...)`, `${arr[0]}`, `${arr[@]}`, `${#arr[@]}`
- Functions with local variables
- Extended test command: `[[ ]]` with regex support

### Commands

File operations:
- `cat`, `ls`, `cp`, `mv`, `rm`, `mkdir`, `touch`, `ln`
- `find`, `stat`, `du`, `tree`, `file`, `readlink`

Text processing:
- `grep`, `sed`, `awk` (full implementations)
- `sort`, `uniq`, `head`, `tail`, `wc`, `cut`, `tr`
- `rev`, `tac`, `nl`, `fold`, `paste`, `comm`, `diff`, `expand`

Data tools:
- `jq` (comprehensive JSON processor)
- `curl` (HTTP client with network allowlists)
- `markdown` / `md` (Markdown to HTML)
- `base64`, `md5sum`

Shell builtins:
- `echo`, `printf`, `pwd`, `cd`, `export`, `unset`
- `test`, `[`, `[[`, `true`, `false`, `:`
- `set` (shell options: `-e`, `-u`, `-o pipefail`)
- `source`, `.`, `read`, `exit`, `return`
- `local`, `declare`, `typeset`
- `break`, `continue`, `shift`, `getopts`, `trap`

Utilities:
- `seq`, `date`, `sleep`, `basename`, `dirname`
- `which`, `env`, `printenv`, `hostname`
- `xargs`, `tee`

[Unreleased]: https://github.com/elixir-ai-tools/just_bash/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/elixir-ai-tools/just_bash/releases/tag/v0.1.0
