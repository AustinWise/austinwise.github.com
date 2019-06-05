---
layout: post
title: Smallest .NET Hello Worlds
time: 2019-01-01 00:00:00 -08:00
tags:
  - draft
---

# notes

* File Alignment 0x200 (512). So you have to make the PE smaller 512 at a time.
  * Can this be changed?

https://docs.microsoft.com/en-us/windows/desktop/Debug/pe-format


# Versions

VS 2019 16.1

# 1 Visaul Studio File New

4.5 KB

# 2 Trim Stuff in from step 1

Changes:
* delete assembly attributes
* delete manifest
* change tyo x64 to remove `.reloc ` section, relocation directory, and import directory

# 3 ILAsm

Got to 1.5KB by decompiling #2 and r- assembleing without resource.
Remove attribes, make class static, remove constructor, remove args parameter.
Use `/NOCORSTUB` to remove import table again.
Exactly 1024 bytes

# 4 .NET Core

Includes DLL and deps file. No .exe file. Framework dependent.
