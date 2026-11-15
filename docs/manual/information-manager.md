<div class="cover">
<div class="cover-brand">VideoBrain</div>
<div class="cover-title">Information Manager<br>Owner's Guide</div>
<div class="cover-stripes"></div>
<div class="cover-foot">A reconstructed guide for the VB-1200 prototype cartridge</div>
</div>

<div class="inside-cover">

## About This Booklet

As of November 2026, no owner's manual for Information Manager has been located, and one may never have been printed. The cartridge itself exists as a September 1978 prototype and has been dumped, so this 2026 booklet was written to aid in usage of the software.

It is written in the style of the original VideoBrain booklets; it is not an original Umtech publication. Cover formatting and screen illustrations are approximations based on existing official material. 

The functions were worked out by reading the program code, then iteratively testing on the extracted strings and traced logic. The last page lists which features have been tried on a running machine and which are known only from the code.

The newest version of this guide, along with the VideoBrain MiSTer core itself, is at https://github.com/MiSTer-devel/VideoBrain_MiSTer.

</div>

# Getting Started

## What Information Manager Does

Information Manager turns your VideoBrain into an electronic filing cabinet. You can keep a household inventory, an address list, a record collection, a recipe file: any list where every entry holds the same kinds of information.

You decide what each entry contains. You type in the entries, and Information Manager records them on cassette tape. Later you can look through them, add up the numbers in them, print them, or make a corrected copy.

## What You Need

1. Your VideoBrain Family Computer
2. The Information Manager cartridge
3. VideoBrain Expander 1
4. Cassette tapes for your files. Making a new file or a changed copy uses two tapes: the one you read from (the **playback** tape) and the one you record onto (the **record** tape).

## Starting the Program

Insert the cartridge and turn on your VideoBrain. The opening screen lists the three things Information Manager can do:

```screen
PROGRAM
ENTER
REVIEW
EDIT
:
```

The colon is the **main prompt**. Type the name of what you want to do and press <kbd>NEXT</kbd>. You only need the first letters: `EN` for ENTER, `R` for REVIEW and `ED` for EDIT.

## The Keys You Will Use

<dl class="keys">
<dt><kbd>NEXT</kbd></dt><dd>tells the computer you have finished typing. Press it after every command and every answer.</dd>
<dt><kbd>SPECIAL</kbd></dt><dd>means "I'm finished." Press it at an empty prompt to stop defining fields or to stop entering records.</dd>
<dt><kbd>SHIFT</kbd></dt><dd>switches between letters and numbers, just as on the VideoBrain's own programs. Shift up for field lengths, quantities and prices.</dd>
<dt><kbd>MASTER<br>CONTROL</kbd></dt><dd>starts the program again at the opening screen.</dd>
</dl>

In this booklet, **type** `PRINT ALL` means type the words exactly as shown and then press <kbd>NEXT</kbd>.

# Planning

## Fields and Records

Every Information Manager file is called a **database**. Before you type in any information, you tell the computer how each entry in the database is laid out.

Suppose you want to keep track of what is stored around your house. Each entry describes one item, and for each item you want to know three things: what it is, where it is kept, and how many you have. Those three kinds of information are the database's **fields**. One complete entry, one item with all three fields filled in, is a **record**.

| ITEM | LOCATION | QUANTITY |
|---|---|---|
| CANDLES | KITCHEN | 12 |
| FUSES | GARAGE | 4 |
| BATTERY | KITCHEN | 6 |

Here the whole table is one database. Each column is a field, and each row is a record. A new item is a new record, never a new field.

## Naming Your Database and Fields

Give the database a short name, such as `HOUSE`. Give each field a short name too, because the field name becomes the question the computer asks you when you enter records. A field named `ITEM` will ask you `ITEM:`.

## Choosing a Length

Each field has a **length**: the number of character spaces it holds. A length of 8 holds `CANDLES` with one space to spare. Choose a length big enough for the longest entry you expect. The length is the size of each entry, not the number of entries; you can have as many records as your tape will hold.

## Choosing a Type

Each field also has a **type**, which tells Information Manager what kind of information goes in it.

| Type | Use it for | Example |
|---|---|---|
| `A` | Words and names | CANDLES |
| `I` | Whole numbers | 12 |
| `M` | Money | 3.49 |

Information Manager can add up the numbers in I and M fields, so use a number type whenever you will want a total. For a number field, the length is the number of positions on the screen. Leave room for a minus sign and, in an M field, for the decimal point. Number fields may be from 1 to 15 positions long.

> **Tip:** Plan your fields on paper first. Once records are recorded, the field layout of that database stays the same.

# Creating a Database

## Defining the Fields

Put a blank tape in the record recorder and wind it to the beginning. At the main prompt, type `ENTER`. Information Manager asks for the database name, then asks about the first field:

```screen
DB:HOUSE
NAME:ITEM
LENGTH:8
TYPE:A
NAME:
```

Answer each question and press <kbd>NEXT</kbd>. After TYPE, the computer asks `NAME:` again for the next field. Describe LOCATION (length 8, type A) and QUANTITY (length 4, type I) the same way.

When you have described every field, press <kbd>SPECIAL</kbd> at the empty `NAME:` prompt. The computer asks:

```screen
OK (Y/N)?
```

Look over your fields, then type `Y`. Information Manager records the layout on the tape and is ready for your records.

## Entering Records

Now the computer asks for each field in turn, using the names you chose:

```screen
ITEM:CANDLES
LOCATION:KITCHEN
QUANTITY:12
ITEM:
```

Type each answer and press <kbd>NEXT</kbd>. When you answer the last field, the record goes onto the tape and the computer starts the next record with `ITEM:` again.

When you have entered your last record, press <kbd>SPECIAL</kbd> at the empty first prompt. Information Manager marks the end of the database on the tape and returns to the opening screen.

> **There is no SAVE command.** Information Manager records as you go. Wait until the tape has stopped before you remove it.

# Reviewing

## Looking Through a Database

Put your database tape in the playback recorder and rewind it. At the main prompt, type `REVIEW`. Information Manager reads the layout and the first record, then shows the **command prompt**, a slash:

```screen
/
```

Type `PRINT ALL` to see every record:

```screen
/PRINT ALL
ITEM:CANDLES
LOCATION:KITCHEN
QUANTITY:12
ITEM:FUSES
LOCATION:GARAGE
QUANTITY:4
ITEM:BATTERY
LOCATION:KITCHEN
QUANTITY:6
END OF TAPE
/
```

`END OF TAPE` means the listing is complete. Type `EXIT` to return to the opening screen.

`PRINT` by itself shows just the next record. The tape only moves forward, so to look through the database again, exit, rewind the tape, and choose REVIEW again.

## Short Forms

At the slash prompt, several commands have one-letter short forms. `P ALL` means the same as `PRINT ALL`. The Command Summary at the back of this booklet lists them all. Note that the short forms are exact: `P` works, but `PR` does not.

## Seeing the Layout with DESC

Forgotten how a database was set up? Type `P DESC`. Information Manager shows the database name and each field's name, length and type, without moving the tape.

```screen
/P DESC
DB:HOUSE
NAME:ITEM
LENGTH:008
TYPE:A
```

## Showing One Field with FLD

To list just one field from each record, choose it with FLD before printing:

```screen
/FLD=ITEM
/PRINT ALL
```

This shows only the ITEM of each record. The choice lasts until you leave REVIEW.

# Reports

## Adding Up a Field

Information Manager can count your records and total any number field, sorted into groups. Use three commands before you print:

- `SORT=` names a word field to group the records by.
- `TOT=` names the number field to add up.
- `TOTAL` shows the report once the records have been read.

Rewind the tape, choose REVIEW, and type:

```screen
/SORT=LOCATION
/TOT=QUANTITY
/PRINT ALL
/TOTAL
```

PRINT ALL reads the records, and TOTAL shows each group with its count and total, then the grand total for the whole database. With the household example above, the KITCHEN group has a count of 2 and a total of 18, the GARAGE group has a count of 1 and a total of 4, and the grand total is 22.

Groups appear in the order they were first found on the tape. The report has room for nine groups; any more are added together under OTHER.

> **Tip:** Grouping works best with word fields of length 8. Set up SORT and TOT before you print. For a fresh report, start again from REVIEW with a rewound tape.

# Editing

## Making a Changed Copy

Information Manager never changes your original tape. Instead, EDIT reads the original from the playback recorder and records a corrected copy on a blank tape in the record recorder. Rewind both tapes, then type `EDIT` at the main prompt.

Type `PRINT ALL`. Each field appears in turn, with the cursor under its first letter. Press <kbd>NEXT</kbd> to keep a field as it is, or type a new value and press <kbd>NEXT</kbd>. Each record goes onto the copy as you finish it. After `END OF TAPE`, type `EXIT`.

To check your work, play back the new tape with REVIEW.

## Edit Commands

At the slash prompt, these commands act on the **current record**: the one Information Manager has just read. When EDIT starts, that is the first record.

| Command | What it does |
|---|---|
| `REPLACE` | Asks for new values for every field of the current record. |
| `ADD` | Keeps the current record, then lets you type new records after it. Press SPECIAL to stop. |
| `DELETE` | Leaves the current record out of the copy. |
| `DELETE 3` | Leaves out the current record and the two after it. |
| `DELETE ALL` | Leaves out the current record and everything after it. |
| `DELETE ITEM=FUSES` | Copies records until it finds FUSES, then leaves that one out. |

Commands work forward along the tape. Once a record has gone by, you cannot return to it in this pass. Finish with `EXIT`, which copies any remaining records and closes the copy.

When you search with `DELETE ITEM=FUSES`, an entry that begins with FUSES also matches, and a `*` matches any single letter.

## Combining Two Databases

MERGE joins two databases with the same field layout into one. Put the first database in the playback recorder and a blank tape in the record recorder, rewind both, choose EDIT, and type `MERGE`.

Information Manager copies the first database and then shows:

```screen
REWIND
KEY NEXT
```

Put the second database in the playback recorder at its beginning. Leave the record tape where it is. Press <kbd>NEXT</kbd>, and when the slash returns, type `EXIT` to copy the second database. To add a third, type `MERGE` again instead of EXIT.

> **Note:** The fields must match exactly: same names, order, lengths and types. Information Manager does not check them for you.

# Printing

## Printed Reports

With a printer connected to Expander 1 at 300 baud, add `PTR` to the end of a REVIEW command to print what appears on the screen:

| Command | Prints |
|---|---|
| `P ALL PTR` | Every remaining record |
| `P DESC PTR` | The database layout |
| `TOTAL PTR` | The report from TOT and SORT |

PTR applies only to the command it ends. The next command without PTR goes to the screen alone.

> **Note:** On the prototype cartridge as it was found, PTR hangs the program. On MiSTer, turn on the printer fix described on the MiSTer page before you use it.

# Reference

## Command Summary

**At the main prompt (`:`)**

| Command | Short | Does |
|---|---|---|
| `ENTER` | `EN` | Create a new database |
| `REVIEW` | `R` | Read a database |
| `EDIT` | `ED` | Make a changed copy |

**At the command prompt (`/`)**

| Command | Short | Where | Does |
|---|---|---|---|
| `PRINT` | `P` | both | Show the next record |
| `PRINT ALL` | `P ALL` | both | Show (or edit) every remaining record |
| `PRINT DESC` | `P DESC` | both | Show the layout |
| `FLD=field` | | REVIEW | Show only one field |
| `SORT=field` | | REVIEW | Group a report by a word field |
| `TOT=field` | | REVIEW | Choose the number field to add up |
| `TOTAL` | `T` | REVIEW | Show the report |
| `REPLACE` | `R` | EDIT | Retype the current record |
| `ADD` | `A` | EDIT | Insert new records |
| `DELETE` | `D` | EDIT | Leave records out |
| `MERGE` | `M` | EDIT | Continue with another tape |
| `EXIT` | `E` | both | Finish and return |

Add `PTR` after PRINT or TOTAL commands in REVIEW to print as well.

## Messages

| Message | Meaning |
|---|---|
| `OK (Y/N)?` | Check your fields, then answer Y to record them. |
| `END OF TAPE` | The last record has been read. |
| `? ?` | The command was not understood. Check its spelling and the prompt. |
| `I/O ERR` | The tape could not be read. Check that it is in the right recorder and rewound. |
| `REWIND` / `KEY NEXT` | MERGE is ready for the next database. |

# MiSTer

## Using This Guide on MiSTer

On the VideoBrain MiSTer core, the two cassette recorders are tape images, and the VideoBrain keys are on your PC keyboard.

| VideoBrain | PC keyboard |
|---|---|
| NEXT | F3 or Enter |
| SPECIAL | F4 or End |
| MASTER CONTROL | Esc |

Load Expander 1 firmware along with the cartridge. In the OSD's Tapes menu, **Mount Playback Tape** is the playback recorder and **Mount Record Tape** is the record recorder. For a blank tape, copy `examples/blank-tape.vbt` to a new name and mount the copy. Use **Rewind Playback Tape** before REVIEW or EDIT; mounting an image also rewinds it.

The user LED shows tape activity. Wait for it to go out before changing tapes or cores.

For printing, set **Printer > Info. Manager Fix** to On before loading the cartridge, then mount a printer capture image, set it to 300 baud and start capture before using PTR. See `docs/PRINTER.md` and `docs/TAPE.md` in the core's repository, and `docs/INFOMAN-MANUAL.md` for the full technical guide.

<div style="break-before: page"></div>

## How This Guide Was Checked

Tried on the MiSTer core: creating, reviewing and editing a database with one 8-character word field and one record, reading a changed copy back, P DESC in REVIEW, and PTR, which hangs the original cartridge. The core's **Printer > Info. Manager Fix** option (off by default) patches the loaded cartridge so the printer can be used; set it before loading and reload after changing it.

Worked out from the program code but not yet tried on a running machine: databases with several fields or records, number fields, FLD, SORT, TOT and TOTAL, ADD, REPLACE, DELETE and MERGE. If something here does not match what your VideoBrain does, the cartridge is right and this booklet is wrong. Please report it at the address on the inside cover.