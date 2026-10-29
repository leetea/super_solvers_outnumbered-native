# Original resource recovery findings

The source archive contents were read only. All 16 original files were hashed before extraction and rechecked after resource generation. `asset_catalog.json` carries file hashes, source offsets, record IDs or ordinals, compressed/decoded hashes, dimensions, decoded-file paths and PNG hashes.

## Recovered assets

- 389 original bitmap records: 363 have exact size `18 + width*height/2`; 26 have explicit trailing bytes. For the latter, `.declared.png` renders only the original declared dimensions, raw decoded bytes and trailers are retained, and a full-row storage preview is exported when possible. The trailer's purpose is unresolved.
- 430 original font glyphs: 413 monochrome glyphs in five original font records and 17 colored calculator glyphs.
- 11 x86 drawing-routine candidates in TEMPLATE.GRA, cataloged as executable data and not executed.
- 89 other structured records, cataloged and preserved without assigning an unsupported image or game-rule meaning.
- All original GRA containers were traversed to their declared end. No compressed block failed decoding. Resource recovery does not establish complete original runtime behavior.

## Original rooms and panels

DMOCKET.GRA is an indexed resource container. ID offsets and hashes are in the manifest.

| Record ID | Visual content | Declared dimensions |
|---|---|---|
| 0x00bf | News room, broadcast desk/map/weather screen | 320x143 |
| 0x00c1 | Game show room, prize board/spinner/jukebox | 320x143 |
| 0x00c4 | Sound room, piano/music shelves | 320x143 |
| 0x00c5 | Cartoon room, painting board/camera | 320x143 |
| 0x00c6 | Equipment room, editing console/Great Eight machine | 320x143 |
| 0x157c | Robot hands around television close-up | 320x145 |
| 0x1770 | Secret-code decoder and room choices | 304x141 |
| 0x1771 | TV Station / Match Rule / Decide buttons | 216x36 |
| 0x1b58 | Small zapper icon | 32x26 |
| 0x1b62 | Notes clipboard | 320x94 |
| 0x1b63 | Lined notes paper | 320x94 |

News room 0x00bf contains one additional stored row: decoded extent 23,058 bytes, declared bitmap extent 22,898 bytes, trailer 160 bytes. Its `storage-preview.png` is 320x144. There is no established basis for changing the declared display height to 144.

## Hallway visual components

FASTLOAD.GRA records 137 through 174 are 38 consecutive 8x94 wall strips. Concatenating them in stored order yields a visually coherent 304x94 wall with a blue/white upper surface, teal panel band and gray base. The derived preview is cataloged with its component ordinals. This establishes recoverable wall texture, not the original hallway placement or scrolling rules.

FASTLOAD.GRA visual identifications:

| Ordinal | Content | Dimensions |
|---|---|---|
| 117-121 | News / Game / Cartoon / Equipment / Sound door labels | See manifest |
| 122 | Elevator surround | 128x84, 192 trailing bytes |
| 123 | Hallway edge/perspective strip | 24x120, 168 trailing bytes |
| 124 | Door and surround | 72x68 |
| 125 | Standing microphone | 56x87 |
| 126 | Television camera | 96x87 |
| 127 | Director's chair | 40x87 |
| 128 | Cactus | 56x87 |
| 129 | Sofa and pictures | 96x87 |
| 130 | Television | 40x87 |
| 131 | Plant | 56x87 |
| 132 | Boom microphone | 56x87 |
| 133 | SGTV reception desk | 128x87 |
| 134-136 | Door-turning/opening poses | 56x67 |
| 137-174 | Wall strips | 8x94 each |
| 175-178 | Elevator opening poses/sections | 16/24/32/48x62, explicit trailing rows |
| 179 | Elevator interior | 96x62, 96 trailing bytes |
| 195 | Energy supply machine | See manifest |
| 196-202 | Energy effects | See manifest |

## Player and enemy poses

`frame_classification.json` records visual groupings. They identify content, not proven animation sequences or timing.

- FASTLOAD 0-8: right-facing locomotion poses.
- 9-13: back-facing locomotion; 14-18: front-facing locomotion.
- 19-22 and 23-26: smaller back/front player poses.
- 27-29: airborne/kicking poses; 30-34: impact/stun/recovery poses; 35-43: flip/fall poses; 44-46: stunned seated poses.
- 47-49: zapper firing poses; 50-55: outgoing zap effects.
- 99: another airborne player pose.
- 100-114: Telly robot movement/damage/knockdown poses. 112 has the lit yellow screen.
- 180-188, 191-192: additional Telly poses; 189-190 and 193-194 are associated effects.
- 203: player back-facing pose; 204-208: moving hat/impact pieces; 209-212: BOOM/ZAP/CRASH/BLAST word effects.

ROOMS.GRA includes LiveWire effects, zapper icons, monkey trick poses (8/9), clipboard bar (14), calculator (15), question/answer frame (16), another UI panel (17), and a small control (18). It is not the collection of room backgrounds.

## Teaching templates

All eleven compressed odd-ID templates are 176x137:

- 0x2135: United States map.
- 0x2137: lined chart.
- 0x2139: Prize is Right gifts/prices.
- 0x213b: music-note chart.
- 0x213d: three measurement columns.
- 0x213f: spinner.
- 0x2141: television frame.
- 0x2143: yellow grid/chart.
- 0x2145: colored rectangular chart.
- 0x2147: Video Cassettes frame.
- 0x2149: smaller yellow grid/chart.

The neighboring even IDs begin with an x86 function prologue and are preserved as drawing-routine candidates. Later IDs 0x2332 and higher decompress to structured numerical records rather than bitmaps. Their semantics need original-code analysis.

## Original fonts and help

MOCKET.DAT font records:

- 0x1392: 18-glyph limited large font, character mapping unresolved.
- 0x1393: 109-glyph UI/help font, beginning at ASCII 33, with original arrow and keycap glyphs through C.
- 0x1394: 90-entry large mathematical font; many unsupported character slots are placeholders.
- 0x1395: 94-entry smaller mathematical font; many unsupported slots are placeholders.
- 0x1396: 102-entry smaller UI font beginning at ASCII 33.
- 0x2198: 17 colored calculator glyphs: digits 0-9, space, +, -, *, /, =, r.

Monochrome font structure: `u16 count`, `u16 space_width`, `u16 offsets[count]`, then glyph records. Each glyph has five little-endian words: x offset, y offset, pixel width, row byte count, height; followed by MSB-first monochrome rows. Glyph PNGs, atlases and JSON metrics are exported. Advance `x+width` is a candidate metric; original font rendering should establish exact placement/spacing.

`original_help.md` and `original_help.json` preserve 22 literal text spans with exact HELP.DAT offsets and raw hexadecimal bytes. Original `~XXXYYY` position commands are removed only in the readable text; they remain in the raw fields. Key labels are established by the original 0x1393 glyphs. The original erase key is labeled **Del**.

Known rules and controls are separately recorded in `help_rules.json`, each tied to HELP.DAT offsets. Exact time rate, movement speed, animation timing, scoring formulas, drill counts and challenge generation remain unresolved by this resource work.
