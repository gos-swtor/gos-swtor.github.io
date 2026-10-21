# Share scripts and ask useful questions

## Support and script contributions

Use the [GoS:SWTOR feature and support thread](https://gamingonsteroids.com/topic/1249-detailed-explanation-of-all-features/)
on the Gaming On Steroids forum. For a particular official script, use its
discussion link in **Official Script Library** (the globe button); hover it to
check the destination. The [Operative / Scoundrel thread](https://gamingonsteroids.com/topic/1252-operativescoundrel-pvepvp-combat-routine-level-80/)
is one example.

The public [official-scripts repository](https://github.com/gos-swtor/official-scripts)
contains the distributed Lua packages, READMEs and changelogs. Read its
[package format](https://github.com/gos-swtor/official-scripts/blob/main/PACKAGE_FORMAT.md)
before proposing a package change. Fork that repository and open a
[pull request](https://github.com/gos-swtor/official-scripts/pulls) with the
proposed patch, required helpers and a clear statement of what you tested.
Include the matching README/changelog changes for user-facing behavior.
Published version folders are immutable: describe a fix against an existing
version as a proposed change, not a replacement release with the same version.
Maintainers review/test accepted changes, carry them into the development
source with attribution, and export a new package version and catalog update.

For documentation corrections or a new example, open a
[documentation pull request](https://github.com/gos-swtor/gos-swtor.github.io/pulls)
with the page URL and proposed text/code. The public repository includes editable
Markdown pages; its [contribution guide](https://github.com/gos-swtor/gos-swtor.github.io/blob/main/CONTRIBUTING.md)
explains which files to edit. You can also post a correction in the support
thread. State whether an example is a complete script or a fragment, which helper
files it requires, and whether it was tested in game. Maintainers review accepted
corrections before rebuilding and publishing the site.

## Link directly to the relevant contract

Open the API entry or guide, select the heading link, and copy its URL into your forum post. Each callable has a stable page. Search can find names such as `gos.abilities.cast`, `definition_key`, or `incoming damage`.

A useful question includes the observed behavior, the expected behavior, the relevant public API entry, and a short reproducible Lua snippet. Include any pending, unavailable or truncated result fields.

## Keep reports minimal and private

Share only the snippet and public result fields needed to explain the problem.
Remove account identifiers, character names, credentials, personal paths and
unrelated logs before posting.

## Contribute more than reference entries

Examples, explanations of data availability, bounded data structures, UI patterns and module organization are all useful documentation contributions. Label fragments versus complete scripts, list required helper modules, and distinguish static review from in-game testing.
