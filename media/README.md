# Media Conventions

This folder does **not** store raw video/image binaries beyond tiny reference assets — GitHub repos should stay small and fast to clone. Here's where each media type actually lives:

## Screenshots (static images)
- Location: `assets/images/`
- Format: PNG or SVG, ideally under 500 KB each (crop terminal windows, don't screenshot the whole desktop)
- Naming: `<module-number>-<description>.png`, e.g. `02-lvm-vgdisplay.png`
- Usage: embedded directly in the relevant `docs/*.md` file:
  ```markdown
  ![vgdisplay output](../assets/images/02-lvm-vgdisplay.png)
  ```

## Terminal recordings (preferred for command-line demos)
- Tool: [asciinema](https://asciinema.org/) — `asciinema rec demo.cast`
- The `.cast` file is plain text/JSON and safe to commit if you want it offline, but it's simplest to upload:
  ```bash
  asciinema upload demo.cast
  ```
- Embed the returned link as a playable badge in a doc or the README:
  ```markdown
  [![asciicast](https://asciinema.org/a/<id>.svg)](https://asciinema.org/a/<id>)
  ```

## Full screen-recorded demo videos
- Do **not** commit `.mp4`/`.mov` files to git — they bloat every clone forever, even after deletion, unless you rewrite history.
- Two supported options:
  1. **YouTube (unlisted or public)** — upload, then link/thumbnail it in the README or relevant doc.
  2. **GitHub's native upload** — open the README (or any Markdown file/Issue) in the github.com web editor and drag the video file into the text box. GitHub uploads it to its own CDN and inserts a working `https://github.com/user-attachments/assets/...` embed URL automatically. This only works through the web UI, not git push — do it once the repo is live, then copy the generated markdown back into your local file and commit that.

## Suggested demo videos for this project
- `01` — creating users/groups + testing sudo policy
- `02` — LVM: creating PV → VG → LV → filesystem → persistent mount, live
- `04` — SELinux denial → `ausearch`/`sealert` diagnosis → fix with `semanage`/booleans
- `07` — before/after: password login working, then locked to keys-only, verified with a failed password attempt
- `10` — full `ansible-playbook site.yml` run against a fresh VM, idempotent second run showing zero changes
