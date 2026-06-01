# tests/smoke.star — stable across upstream JFrog CLI releases.
# Asserts behavior/contract (exit codes, version digits, env-var honoring,
# file side effects), never upstream-controlled prose. See testing-practices.md.
JF = "jf.exe" if ocx.target_platform.os == ocx.os.Windows else "jf"

# Tier 1 + 2: liveness on the composed PATH + version shape.
# `jf --version` prints e.g. "jfrog version 2.105.0" — match the digits only.
r_version = ocx.run(JF, "--version")
expect.ok(r_version)
expect.matches(r_version.stdout, r"\d+\.\d+\.\d+")

# Tier 4: JFROG_CLI_HOME_DIR wiring. Point the CLI at a scratch home that does
# NOT yet exist and prove the executable honors the env var by creating its
# state directory there. `jf config show` reads/initializes the CLI home; on a
# fresh home it exits 0 and materializes the home directory tree. Assert the
# binary created the directory where the env var pointed (the side effect),
# not any specific config filename (those carry a version suffix and churn).
home = ocx.scratch_root + "/jfrog-home"
r_config = ocx.run(JF, "config", "show", env={"JFROG_CLI_HOME_DIR": home})
expect.ok(r_config)
expect.true(ocx.exists("jfrog-home"))
