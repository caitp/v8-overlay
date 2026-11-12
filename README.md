# V8-OVERLAY

This adds some tools you can use to make development a bit nicer on Windows. It is recommended
to add "{V8 workspace}\tools\dev" to your PATH.

The "v8" subdirectory represents the root directory of the v8 repository,
and any files within it are included in the overlay.

While you can simply copy the files in, the [installation](#installation)
process generates a git patch which can be applied, which helps to know if
something is no longer compatible for whatever reason, if the patch fails
to apply.

Adding the files to .git/info/exclude in the v8 directory can now also be
automated without adding duplicate information to the file, however the process
of doing all of this should be easily documented so you can do it yourself
if you prefer.

## Installation

To make things easy, you can use the batch files.

- *install.bat*: Provides a simple way to apply the files to your v8 repository. It wraps everything in a nice convenient package. If no arguments are supplied, it will prompt for the location fo the v8 repository, and force whether or not to remove files that already exist if the patch does not apply clean.
- *mkoverlay.bat*: Generate a patch file and file list, which can be used by *install.bat*.
- *add-excludes.bat*: Similar to install.bat, but will only edit .git\info\exclude. Currently, it adds /patches as an exclude, because typically that folder will contain... patches, that are not intended to be checked into v8. You may or may not want this. Consider making this a prompt-able/optional feature?

However, there's always the option of doing it all manually.

It's recommended to add the overlay and any patches to include into .git\info\exclude, so that
they are never accidentally checked into v8.

I would suggest adding the following to .git\info\exclude

- /tools/dev/gm.bat
- /tools/dev/run-tests.bat
- /patches

At this point, simply copy the files into the v8 checkout.

To make it easy, you can generate a patch to apply to v8:

```batch
@echo off
REM in the v8-overlay workspace:
for /f "delims=" %%H in ('git mktree ^<NUL') do set "EMPTY_TREE=%%H"
git diff "%EMPTY_TREE%" HEAD -- > overlay.patch
```

```batch

git apply 
```

## tools\dev\run-tests.bat

Invokes tools\run-tests.py with the system python3 interpreter, and has some logic to guesstimate
the architecture and pass it along automatically, as well as derive the architecture from the outdir
if it can.

Usage example (with tools\dev in your PATH):

```batch
C:\src\v8> run-tests --outdir=out\x64.debug --variants=exhaustive mjsunit
```

## tools\dev\gm.bat

Invokes gm.py with the system Python3 interpreter, with no special logic. Just makes it a bit more
comfortable to use.

Usage example (with tools\dev in your PATH):

```batch
gm x64.release
```

## patches\get-test262-pr.bat

Pull files from a Test262 pull request, and stuff them into test\test262\local-tests.

It is agnostic about the PWD, and requires a path pointing to the root of the v8 workspace
for the second argument.

Usage example:

```batch
patches\get-test262-pr 1234 .
Downloaded harness/typeCoercion.js
Downloaded test/built-ins/BigInt/prototype/valueOf/length.js
...
```
