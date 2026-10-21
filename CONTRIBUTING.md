# Improve the GoS-SWTOR documentation

Read the formatted documentation at https://gos-swtor.github.io/.
The Markdown files in this repository are the editable sources for those pages.

## Propose a correction

1. Fork this repository and edit the relevant Markdown page under `guides/`,
   `api/`, `examples/`, or `index.md`.
2. For API corrections, edit the shared `api/*.md` contract. The individual
   pages under `api/symbols/` are generated from those contracts.
3. If an example changes, keep its fenced Lua and `examples/code/*.lua` download
   consistent. Explain whether it was tested in game or reviewed from source.
4. Open a pull request with the page URL, the correction and supporting evidence.

Leave generated HTML, search assets and `site-manifest.json` unchanged.
Maintainers review proposals against the current API, carry accepted changes
into the authoring project and publish the rebuilt pages with attribution.
Submitting a pull request does not change the live documentation.

Use https://gamingonsteroids.com/topic/1249-detailed-explanation-of-all-features/
for support questions. Remove account details and unrelated logs from reports.
