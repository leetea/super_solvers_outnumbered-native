# Confirmation dialog recovery — local 0.29, October 28, 2026

Exit, saved-game continuation and member removal now use the original game-screen Yes/No presentation instead of macOS alerts. This is a local development checkpoint. The user requested that further GitHub updates wait until the final app is ready; the published repository and previous full source/distribution archives remain at0.28.

## Evidence and layout

The original common descriptor at1862:0305 is14 bytes: style byte, signed x/y words, body far pointer, title far pointer and default-selection byte. Exit uses DS3566/style3/default0, continuation DS123f/style3/default1, and removal DS124d/style3/default0. Runtime callers supply the body pointers; exit title is DS1d44. The exit caller170d:0c03 selects DS1cf5 for ordinary exit and DS1d51 for exit-and-save. Continuation uses DS1efd. Exact raw instructions and byte ranges are in verification/dialog-instructions-0.29.json; the original unpacked executable SHA remains ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464.

Width is max(100, longest measured line+29), height is10*lineCount+45 with another12 for a title. Negative x/y center the panel in320x200. Text starts x+14 and y+9 without a title or y+20 with one. No and Yes have text-area origins right-115/right-55, bottom-35. Panel style3 uses the Esc to Go Back footer and a separator18 pixels above the bottom. The same table confirms style0 File/Help menu separators at18 and style4 Help-page separators at21; native untitled menu separators were missing and are now drawn.

The raw1862:025d key table is Tab, Enter, Escape, N, Y, n, y, F1, Up, Left, Right, Down. Arrow keys and Tab cycle the two selections. Y/N answer directly. Enter accepts the selection; Escape returns-1, distinct from No0. F1 is ignored for the confirmation caller's maximum-selection1. The native adapter also accepts keypad Enter as the same Return character. Modified command/control/option letters cannot be mistaken for plain Y/N, and Shift-Tab is not treated as the source's plain Tab code.

A header-only analysis derivative seeds1862:02b2 (loaded188d2) to decode otherwise indirect branch tails. Only initial IP/CS bytes20–23 differ; code/data and relocations are unchanged. Its provenance is in dialog-analysis/derivation.json. It is analysis-only and excluded from the runtime.

Original1862:0174 highlights rounded buttons through driver04db/104b:0964. That EGA routine XORs planes1–3, mask14; the low plane stays intact. The native Help/menu/button inverter previously used15 and is corrected to14, so black1 and white15 interchange instead of producing blue/yellow. This follows the palette recovery at0.28; it does not establish complete driver mask/occlusion parity.

## Native flow and deliberate adaptations

Confirmation state captures the parent image and retains the parent screen. Its modal guard freezes world/practice/opening updates; world Escape stops that same frame before actor/RNG/clock changes. Input is routed to the dialog before world queues, and opening cancellation restarts its page wait. Closing clears stale ordinary keys before invoking one completion. Game-menu actions are disabled during confirmation. Native mouse clicks on the two buttons are an adaptation.

Saved-game Yes loads the same saved session. No starts a new game only after the explicit choice; Escape leaves the play menu and unfinished game intact. Regular/custom game settings and previous random-stream continuity retain their existing paths.

Removal keeps the native recoverable archive safeguard rather than erasing a DOS profile. Its warning therefore says the name leaves the Sign-In list and the score/save are retained. This is adapted wording, not original text parity. Existing native names longer than the original eight characters are displayed on separate/wrapped lines without modifying the stored name or identity. Escape returns to the removal picker; No returns to normal selection; Yes archives the record and retains its session/history for Game → Restore Removed Member.

## Verification and remaining work

954 native checks pass. Thirty new checks exercise default selections, every cycle key, Y/N/Return/Escape/F1, keypad/modified input, long legacy names, exact source layout offsets, button XOR, same-frame world freeze, parent action isolation, single exit callback, opening wait restart, mouse No, saved-game cancellation/continuation/replacement and recoverable member removal/restoration. Rendered fixture PNGs are headless evidence; native-window results are separate in verification/gui-observations-0.29.json and match all32 compiled sections/484 assets of the candidate.

Native-window checks exercised opening exit/Tab/Escape, removal No, continuation Escape/Yes, the existing Equipment-room saved game and Exit and Save/Yes. The two copied session documents retain identical logical values; profile records/scores are preserved, with only selected member changing. A re-encoded JSON file can change byte order. No original input files or actual user save directory were changed.

The local extracted app passes strict signature verification and all954 checks. A fresh independent source/repository rebuild for this version is deferred to the final distribution gate; do not reuse0.28 packaging evidence as0.29 proof. Native custom-settings/Options/new-user/other dialogs, complete modifier/tab-navigation behavior, ending/rank/midnight fidelity, graphics masks/occlusion, sound calibration and a fresh complete ordinary playthrough remain required.
