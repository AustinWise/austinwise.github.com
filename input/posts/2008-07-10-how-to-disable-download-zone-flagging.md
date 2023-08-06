---
layout: post.liquid
title: How to disable download zone flagging in Firefox 3
published_date: 2008-07-10 00:11:00 -0700
data:
  nolist: true
---

![](/images/FlaggedDownload.png)

You know that really annoying behavior that Windows Xp SP2 added where downloads warn when you try to open them?  The one that brings up the dialog titled "Open File - Security Warning" with the message "Do you want to run this file"?  For some reason the Mozilla guys <a href="https://bugzilla.mozilla.org/show_bug.cgi?id=236771">thought it would be a good idea</a> to add this "feature" it to Firefox 3.

Fortunately it's not too hard to disable the Attachment Execution Service behind this.  According to the <a href="https://support.microsoft.com/kb/883260">Microsoft article about the service</a>, you can disable the service by:

<ol>
<li>Opening <code>regedit.exe</code>.</li>
<li>Navigating to <code>HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Attachments</code>.</li>
<li>Create (or set) the DWORD value <code>SaveZoneInformation</code> to <code>1</code>.</li>
</ol>

This post is mostly for my future reference, but I hope you find it useful too.
