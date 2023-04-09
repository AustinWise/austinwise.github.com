--- 
layout: post.liquid
title: Facebook Graph Theory
published_date: 2007-06-28 11:54:00 -0700
data:
  nolist: true
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

After the AP test, all I had left to do in Calculus BC was to give a presentation at the end of the year on some mathematical topic.  I have always been interested in <a href="https://en.wikipedia.org/wiki/Graph_theory">graph theory</a>, and my partner thought it was an ok idea.  Then I had to find some way to make this abstract subject tangible to my peers (the people doing pi had it easy; all they did was give everyone some pie).
Just about everyone at Mountain View High School is in a social network.  15 of the 20 people in our Calculus class are in Facebook.  So I wrote a few tools to pull the data out of Facebook and make some pretty graphs.  Implementation details after the pictures.
<br /><br />
This is a graph of the people in my Calculus class.  Nothing that interesting going on here.<br />

TODO 2020: find old image.
<!--
<a href="https://img256.imageshack.us/my.php?image=calcclasspb7.png"><img src="https://img256.imageshack.us/img256/2889/calcclasstnie8.jpg" border="0" /></a>
-->

<br /><br />
My cousin Chris went to <a href="http://en.wikipedia.org/wiki/Bellarmine_College_Preparatory">Bellarmine</a> while I went to <a href="http://en.wikipedia.org/wiki/Mountain_View_High_School_%28Mountain_View%2C_California%29">Mountain View</a>.  Our mutual friend T.J. went to Bellarmine for two years and then Mountain View for two.  Below is Chris's graph.  People who go to Mountain View are in blue.  You can see T. J. is better connected to Chris's friends than my group of friends.
<br />

TODO 2020: find old image.
<!--
<a href="https://img256.imageshack.us/my.php?image=chriseh3.png"><img src="https://img256.imageshack.us/img256/2295/christntc8.jpg" border="0" /></a>
-->
<br /><br />

<span style="font-size:130%;">Implementation Details</span>
<br /><br />
To get a social graph, I used the FQL statement shown below (replace {0} with the current user's uid).  Microsoft's <a href="https://www.microsoft.com/en-us/download/details.aspx?id=24998">Facebook Developer Toolkit</a> made it pretty easily to talk to the Facebook rest service.
<blockquote><div><code>SELECT uid1, uid2 FROM friend where uid1 in (select uid2 from friend where uid1 = {0}) and uid2 in (select uid2 from friend where uid1 = {0})</code></div></blockquote>I wrote a small Visual Basic app that generates a graph definition file to feed into <a href="https://www.graphviz.org/">Graphviz</a>.  I ran neato, twopi, and fdp and chose the best looking graph.
<br /><br />
I ran into a few issues getting this to work.  When I created graphs with 500 nodes, the images were so big (tens of thousands by tens of thousands of pixels), the only program I could use with out freezing my computer was IrfanView.  When I got to about 1000 nodes, the Graphviz programs would fail, citing a malloc error.  It was hitting the 2GB user memory limit on 32-bit processes (I could have run a 64-bit version on my Core 2 Duo/Vista x64, but there are no Windows x64 builds).  Also, people with large number of friends (>800) have trouble pulling down all the data from Facebook.
