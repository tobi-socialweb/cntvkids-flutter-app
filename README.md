# CNTVKids Flutter App

## TODOs
Search for "TODO" comments inside files, for specific non-urgent ones.

- [ ] Check mobile platform while app is loading (SoundEffect._audioCache.playBytes(bytes, volume) is only available for Android, not iOS)
- [ ] Implement `audio_service` plugin for background music player

## Build naming convention

```
    build: [mayor].[minor].[patch]
```

If the build is not a release, then add either `a` (for alpha), `b` (beta) or `rc` (release canditate), after the patch number. Then add 6 digits representing the year, month and date (e.g. for the date October 4th of 2015, use `151004`).

Example of beta release number:

```
    build: 3.12.2b210319
```

## Commits
- `master` is protected and needs pull request.
- Use other feature specific branches if needed.
- Avoid commit messages with the "ed" in "added" or "fixed", instead do "add" and "fix".
- Commit atomically, small but functional.
