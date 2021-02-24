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

## Before pushing to `master` branch
- `Flr` plugin is used only to generate code in the `r.g.dart` file, therefore, there is no need to keep it when pushing to `master` branch.
- This also applies to the file `svg.py` that is used to automatically read all svg constants and redo them into the `helpers.dart` file.

## Commits
- `master` is protected and needs pull request.
- Use other feature specific branches if needed.
- Avoid commit messages with the "ed" in "added" or "fixed", instead do "add" and "fix".
- Commit atomically, small but functional.
