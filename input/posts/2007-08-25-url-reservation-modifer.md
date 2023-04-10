---
layout: post.liquid
title: Url Reservation Modifer
published_date: 2007-08-25 16:38:00 -0700
---

Today I am releasing a tool that makes it easy to create URL reservations.  Why would you want to do that?  If you try to use the <a href="https://docs.microsoft.com/dotnet/api/system.net.httplistener">HttpListener</a> class in .NET as a limited user, you need a preexisting URL reservation.  Otherwise you will get an access denied message.  The documentation says to use the <a href="https://docs.microsoft.com/windows/win32/http/httpcfg-exe">HttpCfg.exe</a> tool to create these reservations, but it requires you to use the verbose SDDL language.  My tool has an easy to use interface:
<a href="https://3.bp.blogspot.com/__h2InWDADvE/RtDCLBRUnQI/AAAAAAAAABc/JLyKSM5sdWg/s1600-h/Add+Reservation.png"><img style="cursor:pointer; cursor:hand;" src="https://3.bp.blogspot.com/__h2InWDADvE/RtDCLBRUnQI/AAAAAAAAABc/JLyKSM5sdWg/s400/Add+Reservation.png" border="0" alt=""id="BLOGGER_PHOTO_ID_5102791872386211074" /></a>
<a href="https://3.bp.blogspot.com/__h2InWDADvE/RtDCHBRUnPI/AAAAAAAAABU/3-5X79wh7P4/s1600-h/Url+Acl+Modifer.png"><img style="cursor:pointer; cursor:hand;" src="https://3.bp.blogspot.com/__h2InWDADvE/RtDCHBRUnPI/AAAAAAAAABU/3-5X79wh7P4/s400/Url+Acl+Modifer.png" border="0" alt=""id="BLOGGER_PHOTO_ID_5102791803666734322" /></a>
<a href="https://archive.codeplex.com/?p=UrlReservation">Download the binaries and the source code at CodePlex.</a>
