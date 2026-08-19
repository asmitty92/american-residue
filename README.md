# American Residue Writing Repository

This repository is organized as a writing monorepo.
Each work has its own folder so it can be drafted, built, and released independently.

## Repository Layout

```text
works/
	<work-slug>/
		manuscript/
		metadata/
		assets/
		revisions/
		compiled/
shared/
	branding/
	templates/
scripts/
docs/
tooling/
archive/
```

## Current Works

- loyalty
- one-cell-rural
- quantum-leap
- season
- the-chosen
- cold-impressions

## Common Commands

Build one work:

```bash
scripts/build_work.sh <snake-cased-title> [format]
```

Build all works:

```bash
scripts/build_all.sh
```

Prepare release tag guidance:

```bash
scripts/release_work.sh <work-slug> <version>
```

## Release Strategy

- Use per-work tags: `<work-slug>-vX.Y.Z`
- Upload compiled artifacts through GitHub Releases
- Keep manuscripts and metadata in git, keep compiled outputs ignored

## Documentation

- docs/workflow.md
- docs/releases.md
- docs/naming.md
