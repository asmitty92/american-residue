# Releases

Use per-work semantic tags:

- <work-slug>-vX.Y.Z
- example: loyalty-v1.0.0

## Release steps

1. Finalize manuscript and metadata for one work.
2. Run scripts/build_work.sh <work-slug>.
3. Create and push tag: <work-slug>-vX.Y.Z.
4. Create GitHub Release with matching title.
5. Upload artifacts from works/<work-slug>/compiled/.
