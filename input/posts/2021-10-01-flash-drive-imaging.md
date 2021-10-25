---
layout: post.liquid
title: Flash Drive Imaging - How Hard Could It Be?
published_date: 2021-10-10 23:55:00 -07:00
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

When installing an operating system on a personal computer after downloading it
from the internet there is often a step where you have to prepare bootable media.
That is after downloading a file you have to put it on some sort of physical
media. Once the operating system install is on the temporary media, you can
boot the computer from it to install the software.

In the early days of the PC era the medium was a floppy. As operating systems
got bigger optical media like CDs and DVDs became ubiquitous.
Currently flash drives are commonly used to install operating systems.

Many many aspects of the PC experience are seeped in layers of backwards
compatibility. Bootable media is no different.

### TODO:

* Floppy emulation in CD drives -> CD drive emulation in thumb-drive bootable media
* Approaches to writing flash drives in order of increasing complexity
    * `dd` to drive
    * adjust partitioning tables when writing
        * but don't forget to write all-zero sectors
    * take advantage of UEFI to pull files from ISO to make a regular thumb drive
        * splitting up large files to fit on FAT
    * chain booting solutions
        * write UDF image straight to flash drive, then write a little EFI
          partition afterwards that contains a chain-loading EFI executable to
          load the UDF data. balenaEtcher does this
        * write NTFS filesystem and then write a chain loader that resides on
          FAT. Need to clarify Rufus behavior: does it load a chain loader
          or some sort of pluggable file system driver.
* Some lessons on the tradeoffs between a general solution like `dd` and systems
  that understand the contents of the image more and manipulate them. Basically
  a tradeoff between fidelity to the original image and increase the numbers of
  images that can be successfully written.