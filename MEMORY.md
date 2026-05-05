# Memory  
  
_Last updated: May 4, 2026_  
  
## Memory  

<!-- Things the user has asked to remember. Persistent — only remove or change if the user asks. -->  

- **GitHub Repository**: https://github.com/ellespy/health-hub (Pages: https://ellespy.github.io/health-hub/). Push all changes here automatically. (updated May 1, 2026 — renamed from laura-fitness-app to health-hub)  
- **Ordering preference**: Always sort dropdown/select lists alphabetically, and always sort time-based or scheduled lists (class times, events, etc.) in chronological order. (added May 1, 2026)  
- **GitHub deploy — always this way:** File lives in Google Drive (`Health Hub/index.html`). Laura runs a terminal command on her Mac to push it to GitHub. Claude never runs git push or any bash git commands. At end of session: remind Laura to run her terminal command. (updated May 4, 2026)
- **Correct working folder is Health Hub** — the "Health Tracking System" folder also exists in Google Drive but Laura doesn't know how to remove it; ignore it. All app work lives in Health Hub. (added May 4, 2026)
- **Always wire new gym workouts into the Weekly Schedule dropdowns when adding them.** Any workout added to `BUILTIN_GYM_WORKOUTS` (or via the custom workout modal) MUST also be selectable from the Edit Routine dropdowns on the Weekly Schedule page. The dropdown source is `getWorkoutLibrary()` (which merges `WORKOUT_LIBRARY` + custom workouts). New built-ins also need an entry in `WORKOUT_LIBRARY`. (added May 2, 2026)  
- **Style updated to Kinetic Ethereal v2.0** (May 3, 2026) — dark mode, #131313 bg, #e5e2e1 primary text, #00f5d4 emerald accent, Space Grotesk + Manrope fonts. Contrast fixes applied to all zone cards and inline styles.
