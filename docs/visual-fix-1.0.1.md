# Visual fixes 1.0.1

The October 28 macOS play test exposed issues missed by the 1.0 acceptance checks.
Original videos, screenshots, archive and decoded artwork are unchanged.

- Mirror FASTLOAD 123 at the left hallway ends (scenes 0/5), and use its stored orientation at the right ends (4/9). The scene records retain their recovered positions.
- Preserve FASTLOAD 56's HUD borders. Center Time and Score within their 57-pixel black cells, and show the reference red Energy fill with a gray empty remainder. Saturation remains 48 pixels at 24 energy; internal energy is not capped.
- Use CLOSE1 27 (120x69 speech bubble) for the master's dialogue. Resource 43 was a 32x25 spark, which left the text unbacked and clipped against the scene.
- Keep the player speech backing separate from script animation backing. The first backing includes the entered player for speech cleanup; script erases must use the clean room. After the found script, preserve the opened room for subsequent animation restores. This removes the stale player during departure without erasing the speech-covered player's head.

1,146 native macOS checks and 1,146 Foundation-only shared checks pass. The 28 new rendered checks cover all four hallway ends, Energy fill/remainder/frame/saturation, value centering, both master lines in all five rooms, and absence of the stationary player in a moving departure frame in all five rooms. The Foundation checks run on macOS; they do not establish Windows execution.

Native opening/sign-in displayed. A fresh interactive replay of the affected scenes remains for user acceptance. Windows source and its expected check count are updated locally; the prior Windows executable still contains the old renderer. This historical verification predates the Windows 1.0.2 rebuild.
