# AGENTS.md

## Purpose

This repository builds a custom SwiftLint binary with native extra rules using Bazel.

## Required toolchain

- Bazel/Bazelisk
- Xcode 15+
- macOS 13+

## Version policy in this repo

- Bazel: `9.0.0` (from `.bazelversion`)
- SwiftLint: `0.63.2` (from `MODULE.bazel`)

## Important Bazel settings

`.bazelrc` must include:

```text
common --enable_bzlmod
common --incompatible_autoload_externally=+cc_library,+cc_binary,+cc_import,+cc_test,+objc_library,+objc_import,+CcInfo,+cc_common
build --macos_minimum_os=26
```

The `incompatible_autoload_externally` setting is required for current Bazel 9 compatibility in this dependency graph.

## Canonical commands

Build and run SwiftLint:

```bash
bazel run -c opt @SwiftLint//:swiftlint
```

Print SwiftLint version:

```bash
bazel run -c opt @SwiftLint//:swiftlint -- version
```

Run extra-rules tests:

```bash
bazel test --test_output=streamed @SwiftLint//Tests:ExtraRulesTests
```

Generate Xcode project:

```bash
bazel run :swiftlint_xcodeproj
```

## Custom rule workflow

1. Add Swift files in `swiftlint_extra_rules/`.
2. Keep `swiftlint_extra_rules/BUILD` exposing `filegroup(name = "extra_rules", ...)`.
3. Do not hand-edit generated `extra_rules.swift`; it is produced by Bazel `genrule`.
4. Validate with lint run and `ExtraRulesTests`.

## LLM agent constraints

- Make minimal, targeted changes.
- Preserve Bazel module setup and existing targets.
- Prefer updating docs/config only when needed.
- After changes, run at least one Bazel command to validate behavior.
