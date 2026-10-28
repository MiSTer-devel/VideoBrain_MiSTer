# Release binaries

Binary identities and release-specific setup requirements. Use the [installation guide](../README.md#installing) for current setup and the [accuracy report](ACCURACY.md) for current implementation status.

## VideoBrain 20261026

[October 26 release candidate](../releases/VideoBrain_20261026.rbf).

### Artifact

- File: `VideoBrain_20261026.rbf`
- Published: October 26, 2026
- Publication commit: `079511ab587970900c06f52de6b046b58f5b5ac9`
- Size: 3,052,848 bytes
- SHA-256: `b2312db5294154f9f84a6cd960ee64031505e6be602c4e0ad2577ebf72152195`

The publication commit identifies the tracked binary; its exact build-source revision was not recorded.

## VideoBrain 20261020

### Setup

Install [VideoBrain_20261020.rbf](../releases/VideoBrain_20261020.rbf) in the MiSTer Computers folder. Keep `boot0.rom` and add `boot1.rom` for Expander 1 operation. Tape images use the VBT format; mount separate files for source and output when editing databases.

Keyboard-file controls are under **Input** in this binary. Printer capture images and the Information Manager printer correction are unsupported.

### Artifact

- File: `VideoBrain_20261020.rbf`
- Published: October 21, 2026
- Publication commit: `2a78622aac9ea9429632fdb0fa6938676b1e06e7`
- Size: 2,931,980 bytes
- SHA-256: `509006ce1b73251170104699366b95262db8b6d784eae8c3fc8101138ae60ef0`

The publication commit identifies the tracked binary; its exact build-source revision was not recorded.

## VideoBrain 20261011

Tape and serial communication are unsupported in this binary. APL/S validation covers startup only.

### Setup

Install [VideoBrain_20261011.rbf](../releases/VideoBrain_20261011.rbf) in the MiSTer Computers folder. The combined BIOS filename is `boot0.rom`; rename an older `boot.rom` installation. Information Manager also needs Expander 1 firmware as `boot1.rom`.

This release uses the older joystick OSD: Joystick=On and Stick timing=Curve. Current calibration and preset instructions apply to later sources.

### Artifact

- File: `VideoBrain_20261011.rbf`
- Publication commit: `3cbccd75ce847a9f78de3a1ee2d3f8da98bcc54e`
- Size: 2,858,972 bytes
- SHA-256: `f971ea62db09456726b8cfa6ef5959883516a4f7e98873f6fbd5bf15ab5c2f03`

The publication commit identifies the tracked binary; its exact build-source revision was not recorded.

## VideoBrain 20261007

Audio accuracy is limited in this binary.

### Setup

Install VideoBrain_20261007.rbf in the MiSTer Computers folder. Keep the existing boot0.rom setup. Set Joystick=On and Stick timing=Curve in the OSD. In Gladiator, push fully forward and make a full-extreme circle on each controller at first-game start.

### Artifact

- File: VideoBrain_20261007.rbf
- Recorded source baseline: `c24e29a5ed053d04da9a91f4cea300535a918994`
- Size: 3,090,592 bytes
- SHA-256: `8a750e791493e3117374b50dd719adf87e66d69c2807121feecf7423defe3dac`
