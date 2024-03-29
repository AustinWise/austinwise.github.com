---
layout: post.liquid
title: Wow armory bank parser and some other things
published_date: 2009-04-14 00:43:00 -0700
---

I made several programs while playing World of Warcraft.  He's two of them.

<h4>Bank Parser</h4>
While I was playing the World of Warcraft with my friends, we formed a guild.  We used the guild vault to pool resources in a sort of communist style system.  My guild leader wanted to ensure that everyone was being generally fair with their contribution and usage of resource.  So I endeavored to write a program to analyze the guild bank log from <a href="https://www.wowarmory.com/">wowarmory.com</a>.

Getting at the data is not too hard, as the whole website is sent as XML and then transformed in the browser with XSLT.  I wrote one program to download the XML pages and load and display them.  The code can be found <a href="https://github.com/AustinWise/wow-armory-bank-log-parser/">on Github</a>.

<a href="/images/BankParser.png"><img style="display:block; margin:0px auto 10px; text-align:center;cursor:pointer; cursor:hand;width: 400px; height: 210px;" src="/images/BankParser.tn.png" border="0"/></a>

I'm not posting a binary because this project has not been updated since Blizzard switched to using Battle.net accounts for log-in.  So currently it does not work, but it should not be too much trouble to update it.

<h4>Flying Mount Macro</h4>
Macros have to be less than 255 characters, which makes it more difficult to make.

<div style="clear:both;"></div>
<code>
/run m={1,34,35,40};z=GetZoneText();if IsFlyableArea() and(((z~="Dalaran")or(GetSubZoneText() =="Krasus' Landing"))and(z~="Wintergrasp"))then m={11,26};end 
/run CallCompanion("MOUNT",m[math.random(1, #m)]);
</code>
<div style="clear:both;"></div>

It will randomly select a ground mount while in old world, dalaran (but not Krasus' Landing), or wintergrasp.  While in any other part of northrend or out land, it will select a random flying mount.  It is kinda cumbersome to use, as the mounts are specified by their position in the mounts window.  The first m= is ground mounts will the second is flying mounts.  This only has to be updated every time you get a new mount ;-).

I know there are addons such as Mounted that give you a nice UI and don't break every time a new mount is added, but I found my macro to be more reliable once I got it working.
