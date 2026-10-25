# Energy machine recovery, native0.4

This is a direct native reconstruction of static code/data with separately recorded native-window checks. The DOS executable is never executed. Original archive and local MKV remain read only.

## Placement and earned recharge

Original16c0:000b draws a random index0..8 and uses DS3382's flattened scene/slot array `[2,6,14,16,22,24,28,34,36]`. It restores the old furnishing, copies the newly selected furnishing, retains its startX, then sets kind9, drawY37, endX=startX+12 and sprite195. Native `OriginalWorld.objects` overlays this record without mutating the original scene table. New sessions draw from the same nine candidates; older native sessions receive a location once when resumed. The chosen location is then persisted. Exact original new-game selection/shared RNG and DOS resume placement are not claimed.

Each correct room activity earns2 pending units. Original1b03:013f walks to machine startX+1, plays resource5000 animation15 `[9,10,11,12,203]`, then adds ALL pending units through11b0:0ee0 and clears the pending byte. It plays sound35 and displays9 frames196/197 alternating, each with a30IRQ wait. If no units are pending, it queues original warning4, plays sound36 and displays199/200/201/199, again30IRQ each. It stops sound and plays animation29 `[14,15,16,17,18]` to return. These two player sequences use24IRQ per frame.

Sprite195 is88×87;196..201 are88×24. They overlay the top strip at the same x/y; replacing the entire machine would wrongly remove its lower body. Original renderer backs up/restores this strip. Native drawing retains the base machine and overlays its top strip. Native HUD energy meter now follows11b0:0ee0's two pixels per unit,48pixel saturation at24, without imposing an internal energy cap.

`NativeFountain` retains phase, original credit amount, location, elapsed IRQs and one-time credit flag. During this synchronous action the IRQ counter advances while minute polling is deferred until completion, like the existing native zap. Walking uses native simulation pacing; exact original approach/turn/scroll timing and menu warnings remain incomplete. The native action resumes safely without granting the credits again.

## Evidence and checks

- `fountain-placement-assembly.json`, evidence`ev_102cbcaa636f97734b26e2b1dce06b7a4ce454eefe0a44d703c2cf2016cfe675`: complete placement procedure.
- `fountain-use-assembly.json`: original1b03:013f's approach, animation, credit clear, sound and timed frame loops.
- `energy-add-assembly.json`, `energy-timer-start-assembly.json`, `energy-timer-wait-assembly.json`: energy update/meter bounds and30IRQ deadline semantics.
- `rea-fountain-evidence.json`: complete five-record export, closed Ghidra session. All refer to unpacked analysis derivative SHA256`ff2e0d28e0a6aa8bcf86db1ea8a2980d2ccb1e10dd793bc15ab1bb929697b464`.
- `EnergyLiveWireChecks.swift`: all nine candidate overlays, original table immutability, delayed one-time award, original frame cadence, empty reuse, persisted mid-recharge, lower-body preservation and native interaction dispatch.
- Native-window checkpoint Command-E visibly increased energy10→14 and displayed the machine/approach. Command-L plus Space visibly removed LiveWire and consumed one energy. These are isolated mechanics checkpoints, not historical campaign seeds or a full playthrough. `verification/gui-energy-*.png` and `gui-livewire-*.png` retain captures.

Remaining gaps: automatic warning presentation, exact scripted movement/turning and transition fidelity, calibrated audio comparison and complete session/ending flow. See `livewire-recovery.md` for the independent room-enemy recovery.
