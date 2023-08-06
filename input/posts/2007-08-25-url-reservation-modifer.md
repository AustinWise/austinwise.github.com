---
layout: post.liquid
title: Url Reservation Modifer
published_date: 2007-08-25 16:38:00 -0700
---

Today I am releasing a tool that makes it easy to create URL reservations.  Why would you want to do that?  If you try to use the <a href="https://docs.microsoft.com/dotnet/api/system.net.httplistener">HttpListener</a> class in .NET as a limited user, you need a preexisting URL reservation.  Otherwise you will get an access denied message.  The documentation says to use the <a href="https://docs.microsoft.com/windows/win32/http/httpcfg-exe">HttpCfg.exe</a> tool to create these reservations, but it requires you to use the verbose SDDL language.  My tool has an easy to use interface:

![](/images/AddReservation.png)

![](/images/UrlAclModifer.png)

<a href="https://github.com/AustinWise/UrlAclModifier">Download the source code at GitHub.</a>
