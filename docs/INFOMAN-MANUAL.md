# Information Manager manual

Start with the [Information Manager Owner's Guide](manual/information-manager.pdf) ([Markdown source](manual/information-manager.md)). It is a reconstructed booklet for the September 1978 VB-1200 prototype, not an original VideoBrain manual, and it covers planning a database, ENTER, REVIEW, EDIT, reports, printing, the command summary, messages and MiSTer setup.

This page holds only what the booklet leaves out: MiSTer tape handling, command details that are easy to get wrong, and which instructions have been tried on a running core. The [APPLE tape tutorial](../examples/saves/README.md#information-manager-apple) is a complete worked example.

## Tapes on MiSTer

- The database name entered at `DB:` is separate from the `.vbt` filename. Give a source and its edited output different filenames so that you keep the original.
- For every new database or edited copy, copy [the blank tape image](../examples/blank-tape.vbt) to a new name and mount the copy in **Mount Record Tape**. The first recording after mounting, rewinding the record deck or resetting starts at the beginning of the image.
- Both decks only move forward, and stopping does not rewind. Use **Rewind Playback Tape** or re-mount the image before each REVIEW or EDIT pass.
- Finish through the program (SPECIAL or `EXIT`), then wait for the user LED to clear before changing tapes or cores. **Tape idle** only means the controller is inactive; to confirm a recording, read it back with REVIEW and `PRINT ALL`.

See [tape operation](TAPE.md) for image preparation and controller details.

## Command details

### Prompts and short forms

- The opening `:` prompt checks only initial letters (`EN`, `R`, `ED`) and ignores the rest, so `REVIE` selects REVIEW. The `/` prompt matches whole words against a dictionary: `P` and `PRINT` work, `PR` does not.
- The one-letter forms are `P`, `T`, `E`, `A`, `R`, `D` and `M`. `T` is TOTAL (not TOT), `A` is ADD (not ALL), `D` is DELETE (not DESC), and `R` is REPLACE at `/` although it selects REVIEW at `:`. ALL, DESC, FLD, SORT, TOT and PTR must be spelled in full.
- `PRINT` shows records on the screen; no printer is involved without PTR. `LIST` is not a command.
- REVIEW and EDIT load the first record before showing `/`. `PRINT ALL` starts with that loaded record, while bare `PRINT` advances first, so it skips the first record on a fresh pass.

### Fields

- A text value shorter than its field is stored padded with spaces.
- I and M fields always occupy eight bytes on tape (a sign byte and seven bytes of packed decimal digits). Their length, 1 through 15, is only the entry and display width. Text fields may be up to 126 characters.

### REVIEW

- `P DESC` needs the PRINT or P prefix; bare `DESC` is rejected. It works in REVIEW and EDIT, is read-only, does not advance the tape, and ignores any FLD setting. LENGTH is shown as three digits with leading zeroes.
- `FLD=fieldname` takes exactly one field of any type and is not available in EDIT. There is no field list and no way to reset it: to see all fields again, exit, rewind and re-enter REVIEW. FLD changes only what is displayed.
- `SORT=fieldname` requires a type A field and does nothing without a `TOT=` field. It groups the report only; records are never reordered on tape. Group keys are always eight bytes, whatever the field's length.
- Issuing SORT again clears the groups but not the grand total, and TOT clears the grand total but not the groups. Set both once before `PRINT ALL`, and start a fresh REVIEW pass for a new report.
- PTR goes last, after any selection (`P ALL PTR`, `P PTR`, `P DESC PTR`, `T PTR`), and applies to that one command. It is not accepted in EDIT or after FLD, SORT or TOT.

### Printing on MiSTer

The original cartridge hangs on PTR: its printer routine uses an uninitialized line count and attempts 256 lines of unintended memory. Set **Printer > Info. Manager Fix** to On before loading the cartridge, mount a printer capture image, select 300 baud and start capture before the PTR command. See [printer capture images](PRINTER.md) for setup and export.

Output is the screen text, converted to ASCII: each 16-character screen line is indented five spaces and ends with carriage return and line feed.

### EDIT

- Commands act on the current record and move forward only. A number after DELETE is a count starting at the current record, not a record number. `DELETE 0` also deletes one record.
- `REPLACE` writes nothing immediately. The new values go to the copy when the program next advances, including at `EXIT`.
- `ADD` does nothing once the end of the input has been reached.
- `DELETE field=value` compares from the start of the field, so `ITEM=APPLE` also matches a longer value beginning with APPLE. `*` matches any single character.
- `DELETE ALL` drops the current and remaining source records. Records already copied stay in the output.
- ADD and REPLACE take no arguments.

### MERGE

- MERGE writes no end marker between inputs; only `EXIT` closes the output.
- The output keeps the first database's definition. Later definitions are loaded but neither written nor compared, and database names are ignored. Mismatched layouts produce an unusable copy.
- After a tape swap, `P DESC` describes the later input's definition, not the one recorded on the output.
- Do not rewind the Record Tape at the `REWIND` / `KEY NEXT` pause.

## MiSTer troubleshooting

| Symptom | Action |
|---|---|
| `I/O ERR` on REVIEW | Check that Expander 1 firmware is loaded, mount the database as Playback Tape and rewind. |
| `I/O ERR` on EDIT | EDIT needs both decks: the source in Playback Tape and a separate writable blank in Record Tape. Rewind both. |
| A second read starts at the end or fails | Exit, rewind Playback Tape and enter REVIEW again. |
| `END OF TAPE` with records missing | The message follows any listing. Check the records shown, not the message. |
| The program stalls after a PTR command | Turn on **Printer > Info. Manager Fix** and reload the cartridge. |
| The core reports Tape error | Preserve the image and see [tape operation](TAPE.md). |

## What has been tested

Hardware here means the MiSTer core, not an original VideoBrain.

| Area | Status |
|---|---|
| ENTER, REVIEW and EDIT with one 8-character A field and one record | Tested, including reading back an unchanged and a changed copy. |
| Menu prefixes (`REVIE`) | Tested. |
| `P DESC` in REVIEW; bare `DESC` rejected | Tested. In EDIT it is known from the ROM only. |
| `P DESC PTR`, `P ALL PTR` | Tested with the printer fix. `TOTAL PTR` and a physical printer are untested. |
| Several fields or records, bare `PRINT` | ROM only. |
| I and M fields: entry, overflow, save and reload | ROM only. |
| FLD, SORT, TOT, TOTAL | ROM only, including the nine-group limit and OTHER. |
| ADD, REPLACE, DELETE | ROM only. The record left pending after ADD's SPECIAL, and whether DELETE prompts for the fields it omits, are open questions. |
| MERGE | ROM only. |
| Editing keys within a field; limits on field names and field count | Not yet documented. |

If the program disagrees with the booklet or this page, the cartridge is right.
