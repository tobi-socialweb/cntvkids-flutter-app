# CNTVKids Flutter App

## TODOs
Search for "TODO" comments inside files, for specific non-urgent ones.

- [ ] Figure out suggested video's algorithm.
- [ ] Use the loading gif when getting data for each page.
- [ ] Add config menu/page with theme selection (e.g. grayscale).
- [ ] Add a search menu/page.
- [ ] Test app in old phone versions (find which should be the last stable one).
- [ ] Test app in chromecast & tablets.
- [ ] Document code.
- [x] Use the correct assets (icons, fonts, sounds).
- [x] Finish video controls (play, pause, etc.) similar to YoutubeKids's.
- [x] Add opening animation and sound for the app.

## Build naming convention

```
    build: [mayor].[minor].[patch]
```

If the build is not a release, then add either `a` (for alpha), `b` (beta) or `rc` (release canditate), after the patch number. Then add 6 digits representing the year, month and date (e.g. for the date October 4th of 2015, use `151004`).

Example of beta release number:

```
    build: 3.12.2b211903
```

## Commits
- `master` is protected and needs pull request.
- Use other feature specific branches if needed.
- Avoid commit messages with the "ed" in "added" or "fixed", instead do "add" and "fix".
- Commit atomically, small but functional.
