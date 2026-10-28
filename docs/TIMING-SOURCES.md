# CPU references and timing evidence

Source comparisons checked on October 24, 2026. CPU active cycles, peripheral-device behavior and VideoBrain board elapsed times are separate evidence scopes.

## Source roles

| Source | Establishes | Limits |
| --- | --- | --- |
| [Fairchild F3850](https://datasheets.chipdb.org/Fairchild/F8/fairchild-3850.pdf), Table 3, printed pp. 3-21 through 3-25 (PDF pages 15-19) | Instruction ROMC order, short/long cycles, data-bus timing classes, interrupt restrictions | Does not specify VideoBrain arbitration or external clock stopping |
| Fairchild F8/F3870 User Reference Card, `2033-249-A-75-020` | Manufacturer summary corroborates PK=4, DI/EI=2, BR7=2/2.5, register mappings and arithmetic flag effects | Internal BR7/DC-update errors and F387X scope conflicts; no ROMC phases; see the [card comparison](#fairchild-reference-card) |
| [Fairchild 1975 F8 brochure](https://bitsavers.trailing-edge.com/components/fairchild/f8/Fairchild_Semiconductor_-_F8_Microprocessor_brochure_-_1975.pdf), printed pp. 9-11 (PDF pages 11-13) | Manufacturer summary corroborating BR7 totals, branch masks, IN timing and CPU-port timing exceptions | Summary totals do not specify bus phases or VideoBrain waits |
| Osborne, [*An Introduction to Microcomputers*, Vol. 2, September 1978](https://bitsavers.computerhistory.org/pdf/osborne/books/Osborne_An_Introduction_to_Microcomputers_Volume_2_Sep78.pdf), Chapter 2 | Detailed explanation of cycle overlap, WRITE/ROMC boundaries, F8 I/O and timer behavior | Covers both 3870 and F8 devices; some tables disagree internally; device manuals take precedence |
| Terry Dollhoff, 1979 F8 chapter, [Sean Riddle's scan](https://www.seanriddle.com/f8_info.pdf), printed pp. 70-79 | Separately authored explanation and instruction byte lengths/totals; explicitly defines a short cycle as four clock periods | PK and DI/EI totals conflict with detailed MK3850 sequences; excerpt does not establish table derivation or independent timing measurements |
| Fairchild F3852/F3853 manual and Mostek 1978 data book | Timer sequence, division, reload and interrupts | Input frequency and gating depend on the board |
| [Mostek June 1979 Microcomputer Products Data Book](https://bitsavers.trailing-edge.com/components/mostek/_dataBooks/1979_Mostek_Microcomputer_Products_Data_Book.pdf) | Detailed MK3850/MK3853 timing chapters corroborate the 1978 sequences and completion boundary | Repeated material is not a new hardware measurement; 3870 summary conflicts and decimal-flag annotations remain visible in the [1979 comparison](#mostek-1979) |
| [Mostek 1981 3870/F8 data book](https://bitsavers.trailing-edge.com/components/mostek/f8/1981_3870_F8_Microcomputer_Data_Book.pdf) | Later 3870 technical manual, instruction tables and timer/interrupt timing bounds | F8 device pages are brief summaries; inherited conflicts and 3870 distinctions need separate treatment; see the [1981 audit](#mostek-3870) |
| [Fairchild F8 User's Guide, May 1976](https://bitsavers.trailing-edge.com/components/fairchild/f8/67095665B_F8_Users_Guide_May76.pdf) | ROMC 13 resets interrupt circuitry; event G and the explicit 3851-to-3853 interrupt-logic link corroborate the completion boundary | PSU sections need the SMI differences in section 5.1.2 applied |
| Sean Riddle's connection records and photographs | Net connections and external gate topology | Do not establish propagation delays or internal ASIC behavior |
| Sean's original-machine captures | Observed clocks and requests | Depend on recorded channels, sample resolution, reset and software state |
| Kevtris, *VideoBrain Unwrapped*, Wait States section | UV202 service timing and full-speed CPU halt measurements | Separates a slowed, clock-modified machine from full-speed operation; interval endpoints differ |
| Turner's [overview](https://www.nyx.net/~lturner/public_html/Fairchild_F8.html), [instruction details](https://www.nyx.net/~lturner/public_html/F8_ins.html) and [opcode summary](https://www.nyx.net/~lturner/public_html/F8_opcodes.html) | Instruction index and timing cross-check | Contains discrepancies; resolve them with the device manuals |
| Tobias V. Langhoff's [F8 Optable](https://tobiasvl.github.io/optable/f8/) and [opcode data](https://github.com/tobiasvl/optable/blob/master/_data/f8/opcodes.json), checked 2026-10-24 | Searchable opcode index and instruction-total cross-check; the page credits Pastraiser | Six documented opcode totals disagree with Fairchild Table 3; no ROMC phases or VideoBrain waits; its linked errata page returns 404 |
| E5frog's [Veswiki Opcode page, revision 786](https://channelf.se/veswiki/index.php?title=Opcode&oldid=786), edited 2026-08-07 | Detailed S/L and ROMC columns corroborate the manufacturer sequences, including BR7 | Credits Dollhoff, Turner and the 1976 guide; five totals contradict its own S/L sequences; see the [revision audit](#secondary-table-exceptions) |
| MAME and implementation regressions | Executable models and checks of explicit expectations | Agreement between models is not a hardware timing measurement |

Use manufacturer tables for instruction expectations and board measurements for
VideoBrain waits. Preserve conflicting observations and their endpoints rather
than adjusting constants to average them together.

## Opcode audit

`make test-cpu-opcode-timing` executes the CPU and bus interface against an
independent transcription of Fairchild Table 3. It checks ROMC order and each
cycle's duration, including the terminating fetch. Expectations do not come from
the implementation's `MICROCODE` table.

It covers 242 documented opcodes in four configurations: low W flags all clear
or all set, and ISAR low bits 3 or 7. Each case initializes the scratchpad through
instructions. Undefined encodings, including reserved INS/OUTS ports 2 and 3,
are excluded. External waits are absent. Existing tests cover the larger branch
mask/flag/displacement space and interrupt entry.

On 2026-10-24 all 968 cases passed. This verifies active cycle lengths and ROMC
order for those cases, not electrical setup/hold or exhaustive semantics.

## Instruction discrepancies

Totals use four-PHI units including the overlapping terminating fetch: S=1, L=1.5. These are active cycles; board waits add elapsed time. BR7 totals below are not-taken / taken. Optable was checked on 2026-10-24: 236 of 242 documented opcode totals agree with Fairchild Table 3. VESWiki revision 786 has five summary totals inconsistent with its own detailed sequences.

| Instruction | Main-board total and ROMC sequence | Conflicting summary | Manufacturer corroboration |
| --- | --- | --- | --- |
| PK (0C) | 4: long 12, long 14, short 00 | Optable, Dollhoff and VESWiki summary: 2.5; VESWiki detail sums to 4 | Mostek 1979 p. 451 (PDF 474); Fairchild card pp. 1/2; Mostek 1981 III-62 (PDF 87) |
| DI/EI (1A/1B) | 2 each: short 1C, short 00 | Optable, Dollhoff and VESWiki summary: 1; VESWiki detail sums to 2 | Mostek 1979 p. 452 (PDF 475); Fairchild card pp. 1/2. Mostek 3870 differs; see below. |
| LR W,J (1D) | 2: short 1C, short 00 | Optable and VESWiki summary: 1; VESWiki detail sums to 2 | Mostek 1979 p. 452 (PDF 475); Fairchild card pp. 1/2 |
| LR J,W (1E) | 1: short 00 | Optable and VESWiki summary: 2; VESWiki detail sums to 1 | Same manufacturer locations; Optable also mislabels 1E as LR W,J |
| BR7 (8F) | 2 / 2.5: short 03 / long 01, then short 00 | Turner, Optable and Osborne Table 2-3: 3 / 3.5 | Mostek 1979 p. 454 (PDF 477); Fairchild card p. 2; Fairchild 1975 brochure p. 9 (PDF 11); Osborne Table 2-2; Dollhoff and VESWiki detail |

IN/OUT use long 03 + long 1B/1A + short 00: 4 units, 16 PHI clocks or 8 us at 2 MHz. CPU-port INS/OUTS (0/1) use short 1C + short 00: 2 units or 4 us. External ports 4-F use long 1C + long 1B/1A + short 00: 4 units. Fairchild's 1975 brochure p. 11 (PDF 13) and reference card p. 2 corroborate the CPU-port exception. Reserved A2/A3/B2/B3 remain excluded even when secondary tables assign them external-port behavior.

### Register and flag evidence

[Optable issue 12](https://github.com/tobiasvl/optable/issues/12), opened by e5frog on 2026-07-01, records the following corrections. Manufacturer locations were checked on 2026-10-24.

| Correction | Manufacturer evidence | Current core |
| --- | --- | --- |
| 0E = LR Q,DC; 0F = LR DC,Q; 10 = LR DC,H | May 1976 User's Guide, Table 2-7, printed p. 2-18 (PDF page 59); 1976 Guide to Programming, Appendix D, printed p. D-2 (PDF page 113) | Matches; 11 is LR H,DC |
| 1E = LR J,W | Same manufacturer tables | Matches; 1D is LR W,J |
| 89 AMD modifies O/Z/C/S, preserves I | User's Guide, Table 2-7, printed p. 2-19 (PDF page 60); Guide to Programming, section 6.4, printed pp. 6-3/6-4 (PDF pages 40/41), and p. D-2 | Uses OP_ADDD, which updates all four arithmetic flags and preserves I |
| 8D CM modifies O/Z/C/S, preserves I | User's Guide, Table 2-7, printed p. 2-20 (PDF page 61); Guide to Programming, sections 6.8/6.10, printed p. 6-7 (PDF page 44), and p. D-2 | Uses OP_CMP, which updates flags without writing the accumulator |
| 8F BR7 = 2 / 2.5 | User's Guide, Table 2-7, printed p. 2-20 (PDF page 61); the manufacturer sequences and brochure above | Matches |

The programming guide calls AMD overflow/sign statuses not significant while marking arithmetic flags affected. The core computes AMD flags from the binary sum before decimal correction; the timing regression does not establish exact decimal flag values. Mostek 1979 pp. 453/454 (PDF 476/477) marks CM's O/Z/C/S affected, AMD/ASD C result-dependent and O/Z/S `?` (no meaning, per p. 451). Its 3870 table p. 344 (PDF 367) likewise marks O/Z/S `?`, whereas 1978 p. 20 (PDF 23) and 1981 III-60/61 (PDF 85/86) mark all four affected. None specifies preserving or clearing meaningless decimal flags.

BT tests any selected Z/C/S flag; BF requires all selected O/Z/C/S flags false. ISAR post-increment/decrement wraps only its low three bits. Fairchild's card and 1975 brochure corroborate these rules. POP copies PC1 to PC0 for the main-board F8 (Mostek 1979 p. 452 / PDF 475 and p. 505 / PDF 528); Mostek 3870 exchange descriptions remain unresolved separately.

## Secondary table exceptions

The [VESWiki revision 786](https://channelf.se/veswiki/index.php?title=Opcode&oldid=786), edited by E5frog on 2026-08-07 at 17:02:44 UTC, credits Dollhoff, Turner and the 1976 Fairchild guide. Its 82 instruction, alias and event rows are a synthesis of those sources. Optable credits Pastraiser. Agreement among these tables does not establish independent hardware measurement.

- VESWiki LR W,J has arithmetic-flag dashes despite loading all five status bits. It omits a separate ICB column, so dashes do not establish DI/EI's complete status effect.
- Its branch aliases are not universal for arbitrary W: low nibble 04 makes BT 5 take and BT 1 not take; BF 1 takes and BF 5 does not. BP's positive result has bit 7 clear but W.S set. Do not invert W.S or replace mask tests with those aliases.
- Its INS/OUTS prose includes reserved ports 2/3; detailed labels use 4-F. Generic scratchpad families retain their addressing restrictions.
- Its IRQ total 5.5 covers long 1C, long 0F, long 13 and short 00, excluding the ROMC 10 freeze. RESET's 3.5 covers short 1C, long 08 and short 00. Neither specifies pin latency, reset hold time, oscillator startup or acknowledgement phase.

Dollhoff's *16 bit Microprocessor Architecture* excerpt is attributed on PDF page 1 to 1979 and contains printed pp. 70-79. Page 77 (PDF 4) defines the four-clock unit; pp. 78/79 (PDF 5) give instruction lengths and totals. JMP/PI/DCI are three bytes, immediate ALU/IN/OUT/relative branches two, and remaining documented rows one. The excerpt's derivation and underlying measurements are unspecified. Its table corroborates DS=1.5, ASD=2, PI=6.5, JMP=5.5 and DCI=6; its short-I/O row enumerates external ports 4-7 only.

Dollhoff p. 75 states S=1 for a plus result and warns that JMP/PI modify A; p. 76 describes operand-minus-A compare and H'66' preparation for decimal addition. Page 74 confines ISAR updates to the low three bits despite table shorthand. Page 77's mutually exclusive timer/external enables describe multichip F8 controls, not 3870 enables. Its generic POP copy and shorter DI/EI totals do not resolve vendor/device distinctions.

Krause's July 29, 2024 *f8 Manual* describes a different ISA (reset PC=4000, memory stack and X/Y/Z registers). It is excluded from historical Fairchild F8 evidence.

## Fairchild reference card

The two-page *F8 and F3870 Microprocessor User Reference Card*, identifier `2033-249-A-75-020/5M/500526`, was visually checked on 2026-10-24. Its identifier alone does not establish a publication year. Page 1 has opcode lists, register organization, ports and interrupt controls; page 2 has instruction groups, flags, lengths, totals and conditions. It provides summary evidence, without ROMC phases or VideoBrain waits.

Its grouped table corroborates PI=3 bytes/6.5 units, JMP=3/5.5, DCI=3/6, DS=1/1.5 and ASD=1/2. Page 1 assigns SMI ports 0C/0D to vector bytes, 0E to interrupt control and 0F to timer; 00/10 disable, 01 enables external and 11 internal interrupts.

- Page 1's alphabetical BR7 entry prints `2.5/3`, contradicting its numerical `2.5/2` and page 2's explicit conditions. Its footnote selects the second total when not taken; the blanket three-cycle branch heading does not apply to BR7.
- Page 2's memory heading says increment but prints `DC <- DC - 1`; detailed manuals establish increment.
- Page 2 excludes XDC for F387X, while Mostek explicitly documents an auxiliary DC and XDC. Its shared F8/F3870 title lists two-cycle DI/EI and POP copy without separate vendor rows. Preserve these source distinctions.

## Mostek 1979

[June 1979 Microcomputer Products Data Book](https://bitsavers.trailing-edge.com/components/mostek/_dataBooks/1979_Mostek_Microcomputer_Products_Data_Book.pdf), publication MK79707, has 848 PDF pages. Device tables and timing diagrams were visually checked on 2026-10-24; printed/PDF locations are:

| Device | 1979 printed pages | 1979 PDF pages | Corresponding 1978 PDF pages |
| --- | --- | --- | --- |
| MK3870 | 327-360 | 350-383 | 6-39 |
| MK3850 | 441-466 | 464-489 | 106-131 |
| MK3853 | 503-520 | 526-543 | 168-185 |

The examined MK3850 PDF 464-487 and MK3853 PDF 526-543 substantially reproduce the 1978 descriptions. Reprinting does not establish a silicon revision. Additional board-relevant locations are:

| Subject | Printed pages (PDF pages) | Evidence |
| --- | --- | --- |
| Clock units | 444/448 (467/471) | WRITE falling begins a machine cycle; short/long cycles are four/six PHI periods. |
| SMI timer | 507/508 (530/531), Figure 2/Table 2 | /31 prescaler, polynomial feedback, FE timeout, FF stop and 255-count repeat; 7F=0, C4=100, C8=215, FE=254 are effective count labels. The count-times-31 formula does not replace the device manual's initial-clock phase. |
| SMI source rules | 508-510 (531-533), Figure 4 | Exclusive timer/external enables, masked timer-event retention; control writes clear external requests and timer loads clear timer requests. |
| SMI acknowledgement | 509-512 (532-535), Figures 4/6/7 | Freeze in ROMC 10, vector in 0F/13 and event-G clear at first ISR fetch. |
| PC/DC timing | 514-518 (537-541), Figures 10-13 | Later DC address selection and RAM WRITE timing; no UV202 service/admission duration. |

The MK3870 miscellaneous table p. 345 (PDF 368) reverses LISL/LISU patterns (`6(1bbb)` / `6(0bbb)`). The MK3850 table p. 453 (PDF 476) and 1978 MK3870 p. 21 (PDF 24) give the correct LISU `6e`, LISL `68+e`. SMI event-E text p. 511 (PDF 534) says ICB=0 enables interrupts, conflicting with the CPU description p. 444 (PDF 467) and DI/EI table: ICB=1 enables them.

## Mostek 3870

[1981 3870/F8 Microcomputer Data Book](https://bitsavers.trailing-edge.com/components/mostek/f8/1981_3870_F8_Microcomputer_Data_Book.pdf), 586 PDF pages, was checked on 2026-10-24 against the 1978/1979 material and RTL. Section IV-1..IV-14 (PDF 274-287) contains brief F8 descriptions, not replacement detailed timing chapters. MK3850 is IV-1 (PDF 274); MK3853 IV-7 (PDF 280) is marked NOT FOR NEW DESIGNS, with a blank facing page. No separately labelled errata section was found.

The substantial section-III manual covers the single-chip 3870 family. III-10 (PDF 35) identifies the original MK3870 as MK3870/20; later family members include RAM and serial hardware absent from it. Its binary timer and interrupt controls apply to Expander 1, not the main-board 3853. Relevant tables and diagrams were visually checked because OCR drops overbars, arrows and table alignment.

| Evidence | Location in 1981 volume | Consequence |
| --- | --- | --- |
| Sign is the complement of result bit 7; overflow is carry out of bit 6 XOR carry out of bit 7 | III-16/17 (PDF 41/42), sections 4.5.1 and 4.5.4 | Supports current ALU conventions; contradicts Optable's prose definitions |
| AMD and CM affect all four arithmetic flags | III-60/61 (PDF 85/86), Table 8-4 | Supports the issue-12 correction; not an exhaustive definition of decimal flag values |
| PK is long + long + short, 8 us at 2 MHz PHI | III-62 (PDF 87), Table 8-4 | Supports the current F8 total of four four-PHI units |
| Q/DC/H register mappings and LR J,W direction | III-63/64 (PDF 88/89), Table 8-4 | Agrees with the core's mappings |
| 3870 timer uses half the external time-base frequency, with prescales 2/5/10/20/40/100/200 | III-25 (PDF 50), section 5.2 | Supports Expander clock and timer division |
| Timer reload is 01-to-N; N=00 means 256 counts; timer requests survive masking; load or acknowledgement clears them | III-26 (PDF 51), section 5.3 | Supports current 3870 timer's functional model |
| External requests require local enable; disabling clears them; pulse-width mode uses the trailing edge, other modes the leading edge | III-29/30 (PDF 54/55), sections 5.4-5.6 | Supports current mode/edge/latch rules |
| Timer wins simultaneous requests; vectors are 0020 and 00A0 | III-30/31 (PDF 55/56), section 5.7 | Supports the functional priority and vector values |

These functional descriptions repeat 1978 printed pp. 10-15 and 24 (PDF 13-18 and 27). Device-specific questions remain:

| Question | Source evidence | Current implementation / disposition |
| --- | --- | --- |
| DI/EI duration on a 3870 | III-64 (PDF 89) lists one short cycle, 2 us each at 2 MHz PHI. The 1978 MK3870 table, printed p. 21 (PDF 24), already gives the same totals. The 1979 miscellaneous table, p. 345 (PDF 368), repeats this, despite p. 343 (PDF 366) claiming exact F8 timing. The MK3850 table, p. 452 (PDF 475), specifies two short cycles. | Expander uses the shared F3850 CPU's two-short-cycle sequence. The device/source conflict requires 3870-specific evidence; main-board instruction timing follows the F3850 documentation. |
| POP on a 3870 | III-57, III-62 and III-194 (PDF 82, 87, 219) describe exchanging PO and P; the 1978 p. 20 (PDF 23) and 1979 p. 344 (PDF 367) rows use exchange arrows too. | Shared `f8_busif` ROMC 04 copies PC1 to PC0 without changing PC1, matching the F3850 sequence. Determine whether the exchange description is an actual 3870 distinction or a documentation error before changing Expander return semantics. |
| Request/vector-selection boundary | III-37 (PDF 62), event B, inhibits changes to priority at the end of the freeze cycle. | Expander selects its source at ROMC 0F phase 1. A request arriving between freeze and selection needs a focused 3870 audit. Normal priority tests alone do not establish this boundary. |
| Source-clear and ICB-clear boundary | III-37/38 (PDF 62/63), events E/F and Figure 6-4, place vector-high delivery in a long cycle, then request/ICB clear in the short first-ISR-fetch cycle. This wording is already in 1978 printed p. 13 (PDF 16). | Expander clears its selected request in ROMC 13 phase 6; shared CPU clears ICB there too. This is earlier than the stated fetch cycle. Exact clear edge and simultaneous new-event behavior remain unresolved. The main-board F3853 completion audit is a separate device-specific result. |
| Timer read/load and request synchronization | III-26, III-39 and III-94 (PDF 51, 64, 119) describe synchronization to machine cycles and explicitly bounded timing errors. | Current timer is a functional counter with direct readback and event latches, not the documented internal synchronizer pipeline. Do not interpret passing timer tests as exact pin-to-ISR or readback-phase accuracy. |
| Reset state and timing | III-20/21 (PDF 45/46), section 4.9, preserves the interrupted PO in P and recognizes reset at a machine-cycle boundary, possibly during a multicycle instruction. | Shared bus reset clears both PC registers. Software depending on the saved P needs device-specific reset handling. |

The timer error tables define their endpoints: OUT/OUTS load/start/stop times
are referenced to the end of the last instruction machine cycle; IN/INS reads
use that instruction's last-cycle endpoint; interrupt generation is referenced
to the start of the cycle setting the request latch. They specify free-running
single-interval error of +/-6 PHI periods with zero cumulative error, and
load-to-request error of -2 through -9 PHI periods. These are 3870 timing bounds,
not constants to insert into the 3853 timer or UV202 wait logic.

The 1979 MK3870 p. 337 (PDF 360) repeats the freeze, vector delivery and first-fetch request/ICB-clear description. It does not establish the exact pin-edge latency.

The 1981 timing introduction III-60 (PDF 85) gives an inverted frequency-scaling ratio: elapsed time scales by `4 MHz/(time base frequency)`. Table 8-4 omits BR7 timing despite descriptions at III-52/53 (PDF 77/78) and the listing at III-56 (PDF 81). Its LR W,J row gives 4 us but only one S, rather than the two required by that total.

On 2026-10-24, `make test-cpu-opcode-timing test-expander1` passed 968 opcode cases, timer prescale/mode/readback/interrupt checks and synthetic host-interface/ISR/mask/reset checks. The integration run emits numeric_std metavalue warnings. These checks cover the functional model; the disputed 3870 behaviors require device-specific cases and original-ROM cassette/serial checks.

## Osborne and Fairchild brochure

The 1975 Fairchild brochure p. 9 (PDF 11) gives BR7 2/2.5 and BT/BF mask semantics; p. 11 (PDF 13) gives IN=4 and CPU-port INS/OUTS=2. Osborne's September 1978 chapter supplies the following additional locations:

| Printed page | PDF page | Evidence and consequence |
| --- | --- | --- |
| 2-27, Table 2-2 | 96 | BR7 has short 03 + short 00 when not taken, long 01 + short 00 when taken; no BT/BF-style idle cycle |
| 2-29, Table 2-3 | 98 | The summary contradicts Table 2-2 by giving BR7 3/3.5; this matches Turner's incorrect entry, but does not prove the web table's provenance |
| 2-35 | 104 | Short cycles are four PHI periods, long cycles six; the trailing edge of WRITE defines the cycle boundary |
| 2-36 | 105 | WRITE's trailing edge triggers the next ROMC state; execution overlaps the next opcode fetch, including the final cycle of external-memory/I/O instructions |
| 2-37 | 106 | F8 I/O is inverted and externally low-driven pins combine with output-latch state; reset/power-up pin states are indeterminate, unlike some 3870 ports |
| 2-43 | 112 | The interrupt ROMC sequence is 10, 1C, 0F, 13, 00; timer and external sources cannot both be enabled by the two-bit F8 control code |
| 2-44, Table 2-5 | 113 | Polynomial timer conversion table, including FE=254, C4=100, 28=164 and 7F=0; these are effective count labels, not literal binary counter contents |
| 2-45 | 114 | Timer runs unless FF is loaded, advances once per 31 clocks, and repeats from FE after timeout |
| 2-54 | 123 | Explicitly applies the preceding PSU timer/interrupt description to the 3853, distinguishing its programmable vector and lack of priority output |

The fetch overlap matters when interpreting captures: do not add a separate
fetch cycle to each instruction's published total. Table 2-2 corroborates the
existing timing audit; Table 2-3 must not override its detailed sequence.
Table 2-2 itself has an interrupt-row discrepancy (08 rather than 0F) and lists
INS/OUTS ports 2-15, whereas the Fairchild CPU table documents external short
I/O ports 4-15. Keep those exceptions visible rather than adopting the entire
table as an independent test oracle.

Osborne's initial chapter discussion describes the 3870's different timer/counter
and interrupt controls. It must not be applied to the main-board 3853 timer.
The F8-specific explanation on pp. 2-43 through 2-45, together with the explicit
3853 link on p. 2-54, is the relevant corroboration. The initial two-input-period
timer delay remains established by the F3852/F3853 manual, not this summary.

## F3853 acknowledgement during vector delivery

The Mostek 1978 data book resolves Osborne's ROMC 13 observation with a
device-specific description: printed pp. 171-174 (PDF pages 174-177), Figure 4
and events E-G/Figures 6-7. Event E freezes priority selection in ROMC 10. Event
F supplies vector low in 0F and vector high in 13. Event G clears SERVICE
REQUEST and the appropriate source latch at the 13-to-00 boundary, as the
first ISR instruction fetch begins. Both timer and external timing diagrams
retain their request through vector delivery. This is stronger evidence than
the secondary source's description of a reset somewhere during ROMC 13.

The Fairchild May 1976 User's Guide independently corroborates
this: Table 2-5, printed p. 2-13 (PDF page 54), assigns the interrupt-circuit
reset to ROMC 13; section 3.6.2, printed p. 3-21 (PDF page 90), places event G
at the first ISR fetch. Section 5.1.2, printed p. 5-2 (PDF page 121), explicitly
links the 3853 timer/interrupt handling to the PSU logic, with differences in
priority output and programmable vector. The February 1976 guide makes the
same device link in section 5.1.2 (printed p. 5-5, PDF page 227). The November
1977 compilation retains the May 1976 revision marking on its SMI description
(printed p. 5-1, PDF page 119); its filename does not make that device section
a newer revision. These guides corroborate rather than contradict Mostek's
device-specific sequence.

The bus interface emits its one-MCLK acknowledgement pulse at ROMC 13 phase
11; the F3853 consumes it on the following MCLK, at the beginning of the ISR
fetch. The source request remains latched through vector delivery until event G.

Printed p. 172 specifies separate clears: timer load or timer acknowledgement
clears TIMER INTERRUPT; a control write or external acknowledgement clears
EXTERNAL INTERRUPT. Masked timer timeouts remain latched. Figure 4 shows the
source-clear inputs taking precedence over their set/feedback paths. The F3853
model gives source-specific clear and reload precedence over simultaneous expiry.

No vector latch is needed for new pending events in this single-SMI system:
bit 7 follows the interrupt control mode, not pending-source arbitration.
The CPU executes no I/O writes during 10, 1C, 0F, 13, so neither the mode nor
the programmable vector can change between byte deliveries. A masked timer
expiry during external entry cannot switch the vector or be cleared by the
external acknowledgement. This does not implement multi-device daisy chaining
or guarantee behavior under artificial concurrent register writes.

`make test-smi` includes 104 source/event/half-phase cases across both vector
states and the clearing boundary, checking pending requests, vector bytes,
saved PC, acknowledgement pulse width and enable gating. It also checks
acknowledge/expiry and acknowledge/expiry/reload collisions at dividers 31 and
1. Event offsets refer to the existing RTL's latch inputs: Mostek's two WRITE
synchronizers on each physical interrupt input are not reproduced by this
model, so these tests do not establish pin-edge setup/hold or exact latency
for a physical request arriving immediately around event G. Acknowledgement
timing and the gated-PHI timer input still require hardware confirmation.

## Saved capture inventory

Metadata in Sean Riddle's three reset-capture archives listed below records 12.5 MHz
digital sampling (80 ns samples) and these channel labels:

| Channel | Label | Use |
| --- | --- | --- |
| 0 | 202-7 clock | Unused UV202 CPU-clock output; this is not BRCLK |
| 1 | 3850-38 xtal | Gated external CPU clock |
| 2 | 3850-1 phi | CPU PHI |
| 3 | 3850-37 /reset | Exclude reset and identify restart |
| 4 | 202-2 umi rq0 | UV201 DMA requests |
| 5 | 202-3 cpu rq0 | CPU request 0 |
| 6 | 202-39 cpu rq1 | CPU request 1 |
| 7 | 3850-28 IO16 | Auxiliary I/O activity |

Metadata durations are approximately 11.186 s (`vbnormalwreset.sal`), 10.491 s
(`vbdiagwreset.sal`) and 10.293 s (`vbnobios1wreset.sal`). Names alone do not prove
the ROM bytes or software state. None records BRCLK, WACK, WRITE, ROMC or data.

The older `vbclocksandromcx.jpg` screenshot shows WRITE/ROMC but is a separate
session. `vbxtalyphicrystal.jpg` includes the continuous crystal oscillator,
which is absent from these .sal sessions. Do not combine their sampling rates
or infer a complete opcode stream from the request-only sessions.

The archives contain Saleae's internal format, not its public binary export
format. [Saleae recommends exporting with Logic 2](https://www.saleae.com/support/logic-software/saving-and-exporting-data/sal-file-format).
The CSV exports were analyzed on 2026-10-24, together with a separate Timeshare
Logic 1 bus capture, the paired diagnostic ROM and the Money Minder cassette
transition CSV.

## Board timing status

The gate regression matches an independent ideal U30/U31/U41 model over 76,742
edge decisions. It checks the response to supplied requests and WACK, not the
CPU request-generation phase, UV202 WACK duration, DMA handoffs or propagation.

The 128-offset diagnostic still reports 6-7 lost half-clocks for RAM/cart/RES2
reads and RAM writes, 7-11 for UV201 reads, and 8-9 for UV201 writes, without DMA.
The documented RAM/cart expectation is 7-9, so that assertion fails.

Kevtris's full-speed sunk cost is the last CPU falling edge to the first resumed
falling edge, minus one CPU period. His ASIC service description starts at UV202
request pins, after external synchronizers. It also quotes both 6-9 and 5-8
BRCLK totals for UV201 accesses. Resolve these endpoints before interpreting a
one-BRCLK discrepancy as a missing RTL stage. Full-speed results include
propagation effects absent from the slowed experiments and ideal gate model.

The exported sessions provide same-polarity PHI gap distributions alongside
CPU/DMA requests, with reset exclusion and an 80 ns sampling grid. Clean read
code 11 gaps in the normal capture cluster around 1.76/2.00 us, so adding delay
solely to meet the older approximate sunk-cost account is not justified. The
regression bounds are not original-machine measurements. Access-specific
service and request phase need a matched workload. BRCLK/WACK captures would separate admission,
service and restart costs; the existing channels cannot uniquely determine all
three. Do not impose one screenshot's pattern on every workload.

DC0 reads pause after the third PHI falling edge and writes after the fourth,
matching the captured pause positions. ROMC 02 selects the DC0 address and
starts its request at half-phase 5; the CPU consumes returned data at phase 7.
ROMC 05 holds the address from phase 5 and starts the write request at phase 8.
Active cycle totals and arbiter wait constants are independent of this placement.

Expander 1 selects its interrupt vector at ROMC 0F phase 1 and clears its source
at ROMC 13 phase 6. Its 3870 vector-selection strobe is separate from the
main-board F3853 completion acknowledgement.
