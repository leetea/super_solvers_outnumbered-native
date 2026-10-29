# Security and privacy

The application stores player names, dates and progress locally. Removing a member archives their profile and session; it is not permanent deletion. Use a nickname on shared computers. No account password is needed by this app.

To erase all local player data, quit every running copy of the app, then delete the `OutnumberedNativeReimplementation` folder in your user Application Support folder (macOS) or Local AppData folder (Windows). If `OUTNUMBERED_NATIVE_DATA_DIR` is set, it selects a different save folder. This removes all profiles, archived profiles, sessions and score history in that folder. Backups and copies elsewhere are separate. Do not delete a shared parent folder.

## Build checks

Run `python3 tools/test_security.py` and `python3 tools/check_privacy.py <files-or-package>`.
The scanner checks personal home paths, the personal email domain identified during the audit, common token formats and private-key headers, including ZIP members and UTF-16 metadata. Only the exact generic upstream `swift-ci` build account embedded in official Swift DLLs is exempted from the home-path check; other checks still apply to those DLLs. It prints finding types and locations, never the matched values. It is a regression guard, not a comprehensive secret scanner or malware certification. Screenshots still need visual review.

`tools/sanitize_runtime.py source/runtime-data.zip` replaces only the reference-video fixture's machine-specific path with a relative name and preserves the remaining archive members. Both build entry points run this before unpacking. Windows ships only the four runtime JSON files; development reference fixtures are excluded. Packages are scanned before archiving/uploading. Existing macOS destinations are rejected rather than synchronized destructively.

## Commit privacy

Use a GitHub noreply identity in each local clone before committing:

```sh
git config --local user.email '7686365+leetea@users.noreply.github.com'
```

Also enable **Keep my email addresses private** and **Block command line pushes that expose my email** in GitHub email settings. A `.mailmap` or a new commit does not erase existing metadata. Historical cleanup requires a coordinated rewrite of all affected refs, replacement of retained artifacts and fresh clones. Never force-push a rewritten history without coordinating with collaborators.

## Distribution signing

Current local builds are not publisher-authenticated releases: macOS uses ad-hoc signing and Windows has no publisher signature. Do not describe them as notarized or publisher-verified.

For macOS distribution, set `OUTNUMBERED_SIGNING_IDENTITY` to your keychain Developer ID Application identity and `OUTNUMBERED_NOTARY_PROFILE` to a configured notarytool keychain profile, then run `zsh build.sh distribution`. This mode requires both identities, signs with hardened runtime and a timestamp, submits for notarization, staples and validates the ticket, and requires Gatekeeper assessment before packaging. It never falls back to ad-hoc signing.

For Windows distribution, run `windows/build.ps1` with `-Distribution -CertificateThumbprint <thumbprint> -TimestampServer <trusted-https-url>` in addition to `-SDLRoot`. The certificate must already be installed with its private key accessible to SignTool. This mode signs the final EXE, verifies Authenticode and the selected certificate, then records its hash and packages it; it fails rather than falling back to an unsigned build. Keep private keys in a keychain, hardware token or protected CI secret store; never commit/export them into this repository. Preserve upstream DLL signatures. Actual publisher signing requires the owner's identities and remains a release step.

## Pinned Windows inputs

The workflow pins Action commit IDs and verifies Swift and SDL SHA-256 hashes before execution/extraction. Swift must also pass Windows Authenticode validation. Update versions, hashes and these evidence references together after review:

- Swift 6.4.1 x64: Microsoft WinGet manifest blob `49843cbc951e6a789498d2749dbb7c8b3d7e8d27` in `microsoft/winget-pkgs`, `manifests/s/Swift/Toolchain/6.4.1/Swift.Toolchain.installer.yaml`.
- SDL 3.4.18 VC: `libsdl-org/SDL` GitHub release asset `606657750`; SHA-256 recorded 2026-10-29.

CI uploads successful build outputs only, and no longer uploads the entire test-player directory. Existing artifacts and Git history are not erased by these changes. The 2026-10-29 audit identified private metadata in earlier copies; remove or replace those separately before widening access.
