# From Bench to Deployment — DVCon Europe 2026 tutorial

**Building Deterministic Digital Twins of Cyber-Physical Systems with Frost and Lingua Franca**

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/sbgaia/dvcon26-tutorial)

The tutorial's examples, ready to run. The slides are in
[slide/dvconeu26-tutorial-frost.pdf](slide/dvconeu26-tutorial-frost.pdf).

## Start

1. Click the badge above.
2. When asked for `SYSIDE_LICENSE_KEY`, paste the key you got at the tutorial.
3. In the terminal, check that everything is there:

   ```bash
   lfc --version && sysmlc backends
   ```

## Without Codespaces

### With Docker on your computer

The Codespace is built from [`.devcontainer/`](.devcontainer). In VS Code with
the Dev Containers extension, open this folder and choose **Reopen in
Container**. Or, in this folder, with Docker:

```bash
docker build -t dvcon26-tutorial .devcontainer
docker run -it --rm --user vscode -e SYSIDE_LICENSE_KEY=<your key> \
    -v "$PWD":/workspace -w /workspace dvcon26-tutorial bash
```

The first build takes about 15 minutes.

### Installing everything yourself

You need:

- Java 17 (a JDK), CMake and Python 3.12.
- The Lingua Franca compiler `lfc` 0.13.0, from
  [lf-lang.org/docs/installation](https://www.lf-lang.org/docs/installation).
- sysmlc with Rosetta, from
  [sysmlc-library](https://github.com/glacier-project/sysmlc-library),
  [sysmlc-core](https://github.com/glacier-project/sysmlc-core),
  [sysmlc-models](https://github.com/glacier-project/sysmlc-models) and
  [sysmlc-rosetta](https://github.com/glacier-project/sysmlc-rosetta).
  sysmlc needs a SysIDE license key in `SYSIDE_LICENSE_KEY`.
- [Frost](https://github.com/glacier-project/frost), cloned as
  `lf-packages/frost`, with `LF_PACKAGES` set to that `lf-packages` folder.
  Frost also needs
  [machine-data-model](https://github.com/glacier-project/machine-data-model)
  and `fmpy`. Part 03 needs `matplotlib`.
- For part 05, [reactor-uc](https://github.com/lf-lang/reactor-uc/tree/micromode)
  on branch `micromode`, with `REACTOR_UC_PATH` set to it.

[`.devcontainer/Dockerfile`](.devcontainer/Dockerfile) installs exactly these,
at the versions the tutorial was tested with.

## The examples

| Part | Slides | Folder |
| --- | --- | --- |
| 1 | Lingua Franca | [01-lingua-franca](01-lingua-franca) |
| 2 | Frost | [02-frost](02-frost) |
| 3 | Rosetta: SysML v2 → Lingua Franca | [03-rosetta](03-rosetta) |
| 4 | Hands-on: Ex 0 – Ex 3 | [04-hands-on](04-hands-on) |
| 5 | Hands-on: Ex 4, from model to silicon | [05-silicon](05-silicon) |

Each folder's README lists the commands to type in that folder and the
output you should see. In each folder, `./run.sh` runs the same steps one by
one.

Words you will meet:

- **Lingua Franca (LF)**: a language for deterministic programs made of **reactors**.
- **`lfc`**: the LF compiler.
- **FMU**: a simulation model packaged with the FMI standard.
- **`sysmlc`**: the SysML v2 compiler. It contains **Rosetta**, which turns SysML v2 into LF.

## If something goes wrong

| You see | Do |
| --- | --- |
| `Please provide a license key` or `License key is invalid` | Run `export SYSIDE_LICENSE_KEY=...` with the key from the tutorial, then run the command again. |
| `lfc: command not found` | You are not in the Codespace. |

## Links

- Frost: [github.com/glacier-project/frost](https://github.com/glacier-project/frost)
- Rosetta: [github.com/glacier-project/sysmlc-rosetta](https://github.com/glacier-project/sysmlc-rosetta)
- Lingua Franca: [lf-lang.org](https://www.lf-lang.org) · reactor-uc: [github.com/lf-lang/reactor-uc](https://github.com/lf-lang/reactor-uc)
