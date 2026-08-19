# Workflow

## Daily writing flow

1. Create a new work scaffold: scripts/scaffold_work.sh <snake_case_slug>
2. Edit manuscript files under works/<slug>/manuscript/.
3. Keep work-specific metadata in works/<slug>/metadata/book.yaml.
4. Store generated artifacts in works/<slug>/compiled/.

## Build flow

1. Build one work: scripts/build_work.sh <snake-cased-title> [format]
2. Build all works: scripts/build_all.sh

## Notes

- Compiled artifacts are intentionally ignored in git.
- Publish compiled artifacts through GitHub Releases per tag.
