# Door and elevator transition recovery (0.15 work in progress)

Evidence: unchanged analysis executable; game-pseudocode.c functions 135d:072b (entrance), 135d:0a1c (exit), 135d:039b (elevator), 135d:09af (pose helper), 135d:0243 (elevator panels), 135d:0c41 (room panels), 135d:0cf5 (actor update). The active visual reference remains the supplied local MKV, never the superseded YouTube URL.

## Proven final-state corrections

Entrance locates the hall door and aligns the player's global X to scene*38 + object.startUnit + 1. It forces facing right, then stores the aligned global and screen X in DS:6d6c / DS:5b55. Camera does not change in this sequence. The room starts at its first object's startUnit (5). Exit restores the aligned coordinates, not the original Up-key location, and remains facing right. The previous native implementation stored the pre-alignment coordinates/facing. NativeApp now corrects these endpoints; all five doors and both initial facings have off-centre entry/return checks.

Elevator ends at screen unit12 for origins0/5, unit24 for origins4/9. After the exit animation it explicitly faces right for origins0/5 and left for origins4/9. NativeApp previously retained the input facing. Four elevator checks now begin with the opposite facing and assert the original exit facing.

Endpoint corrections are implemented. Native room-door staging is now integrated in DoorTransition.swift and GameDoorTransition.swift; elevator staging is now implemented in0.16; see elevator-transition-recovery.md. 504 checks now pass, and an ordinary News entrance/exit was observed in the native window. Complete frame/timing parity is not claimed.

## Original room sequence

Entrance: sound3; align horizontally using walking animation2; force right; animation3 frames9..13, dy=-3 each (Y78,75,72,69,66); open hall door using ordinals134,135,136 at y49, retaining rear player frame13; animation5 frames19..22, dy=-4 (Y62,58,54,50); store aligned hallway coordinates; select interior; initialize room/LiveWire; animation6 frames23..26, dy=+4 (Y54,58,62,66); animation4 frames14..18, dy=+3 (Y69,72,75,78,81); idle; guidance5.

Exit: align to interior exit object's startUnit; force right; animation3/-3 then5/-4; restore hallway global and screen X; compose hall with door open (ordinal136); draw frame23 at Y50; clear/reset actors and request floor sound1 or2; animation6/+4; close hall door136,135,134 with player frame18; animation4/+3; idle.

135d:09af explicitly waits24 IRQ ticks per pose frame. Alignment loops and room-panel loops call104b:04de but do not explicitly wait. Direct REA recovery of104b:04de at0x1098e shows a0x13b0-byte planar viewport copy with VGA mode/mask writes, no retrace input, BIOS delay or timer wait. Evidence is verification/display-exchange-0.15.json. Effective duration depended on the original CPU/graphics-memory speed. The native sequence presents each such walking/panel frame for4IRQ ticks (about16.9ms), an explicit native display adaptation; it preserves ordering without claiming original-machine timing parity. The24IRQ pose waits remain recovered behavior.

## Original elevator sequence

Align to elevator.startUnit+5; force right; animation3/-3; open panels in four iterations; animation5/-4; close panels with small rear player; request sound22 for0/4 or21 for5/9; build destination hall; scroll viewport in eight bands (18 pixels each, final band20) with23 IRQ ticks per band; set destination global/screen coordinates; open panels with small front player23; animation6/+4 then4/+3; close panels retaining front player18; set side-specific final facing; idle.

Panel graphics: helper0243 uses base sprite179 at y53 plus two mirrored panels. Opening uses177,176,175,then none; closing uses175,176,177,178. Exact right-panel placement depends on DS:5b69 (sprite width) and original driver X groups; retain that distinction from player8-pixel units. Opening/closing waits23 IRQ ticks each.

## Local visual check

verification/local-elevator-transition-contact-0.15.png samples the local MKV from82 through89.75 seconds at4fps, row-major8x4. It shows News exit rear/front poses, walking/scrolling toward the left elevator, alignment, rear shrink, panel opening and closure. This independently confirms that the instant native transition omits visible stages. The contact sheet alone cannot resolve every30fps pose/panel boundary. Full-rate extraction around the elevator and room doors is the next reference check.

## Remaining work

Room-door staging now preserves alignment/pose/panel order, suppresses input during the original synchronous sequence, retains IRQ time without main-loop minute polling, initializes the destination once at the midpoint, and stores the stage in a new optional native-save field. Legacy saves omit that field. Verify native-window flow and resume behavior, the elevator pose/panel/viewport stages are now implemented in0.16. Room-door stages form milestone0.15; elevator staging now forms milestone0.16; detailed camera and auxiliary actor parity remain required. Packaging/publication status is tracked in repository-sync.json. Broader scroll/knockback/occlusion and timed activity effects remain part of the full-game goal.
