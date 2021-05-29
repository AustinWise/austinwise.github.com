--- 
layout: post.liquid
title: HttpListener and URL ACLs
published_date: 2006-04-10 23:03:00 -07:00
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---
UPDATE: A new version of my tool is available <a href="/2007/08/25/url-reservation-modifer.html">here</a>.
<br/>
<br/>

I recently reinstalled XP and decided to try not running as admin.  Everything was going fine until I tried to run a little app of mine that used a <a href="http://msdn2.microsoft.com/en-us/library/system.net.httplistener%28VS.80%29.aspx">HttpListener</a>.  Upon trying to start, the HttpListener threw a <a href="http://msdn2.microsoft.com/en-us/library/system.net.httplistenerexception%28VS.80%29.aspx">HttpListenerException</a> exception with a message of "Access Denied".

After spending a lot of time on Google and MSDN, I discovered that non-Administrators can't start listening on any port they want.  The url they want to use has to be first reserved by an Administrator for that user.  This can be accomplished through the use of the tool <a href="http://msdn.microsoft.com/library/default.asp?url=/library/en-us/http/http/httpcfg_exe.asp">HttpCfg.exe</a>.  HttpCfg is part of the Windows Support Tools, which can be downloaded for <a href="http://www.microsoft.com/downloads/details.aspx?FamilyID=9d467a69-57ff-4ae7-96ee-b18c4790cffd">Windows Server 2003</a> and <a href="http://www.microsoft.com/downloads/details.aspx?FamilyID=49ae8576-9bb9-4126-9761-ba8011fabf38">Windows Service Pack 2</a>.

HttpCfg is non-user-friendly command-line only tool.  It requires entering in <a href="http://www.washington.edu/computing/support/windows/UWdomains/SDDL.html">SDDL</a>  strings.  I was also unable to find any managed interface to talk the <a href="http://msdn.microsoft.com/library/default.asp?url=/library/en-us/http/http/http_server_api_version_1_0_reference.asp">HTTP API</a>. So I tasked myself with creating a managed interface for the HTTP API and an application that makes it easy to manipulate URL ACLs.

I made it, but right now it only supports one user per URL ACL.  This is my first time doing interop with native code, so that part might not be correct.  It seems to work though.  Once I add support for multiple users, I thick I will write an article on <a href="http://www.codeproject.com/">Code Project</a> about it.

<strike><a href="#">Download</a> and use at you own risk.  The code in that download is copyright 2006 Austin Wise, but the final release might use a different license.</strike>
