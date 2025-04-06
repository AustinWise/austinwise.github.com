---
layout: default.liquid
title: Home
permalink: /
---

<img id="myPic" src="Me.V4.jpg">
<h2>About Me</h2>
<div>
	I am a software engineer.
	I enjoy fiddling with computers.
</div>

<h2>Selected Github Projects</h2>
<ul class="posts">
	<li><a href="https://smeagol.dev/">Smeagol</a> A Rust-based personal wiki.</li>
	<li><a href="https://github.com/AustinWise/DinnerKillPoints/">DinnerKillPoints</a> An ASP.NET Core website for tracking debts between friends</li>
	<li><a href="https://github.com/AustinWise/TaxStuff/">TaxStuff</a> basic federal tax return calculator</li>
	<li><a href="https://github.com/AustinWise/ZfsSharp/">ZfsSharp</a> A .NET program that reads the ZFS filesystem.</li>
	<li><a href="http://github.com/AustinWise/">Additional projects</a> Publicly available on GitHub.</li>
</ul>

<h2>Blog Posts</h2>
<ul class="posts">
	{% for post in collections.posts.pages %}
		{% if post.data.nolist %}
		{% else %}
 <li><span>{{ post.published_date | date: "%Y-%m-%d" }}</span> &raquo; <a href="{{ post.permalink }}">{{ post.title }}</a></li>
		{% endif %}
	{% endfor %}
</ul>

<!--
<h2 id="pr">Accepted Pull Requests</h2>
<ul class="posts">
	{% for pull in site.data.pull_requests %}
		{% if pull.pending == 'true' %}
		{% else %}
<li><span>{{ pull.date }}</span> &raquo; <a href="{{ pull.url }}">{{ pull.title }}</a></li>
		{% endif %}
	{% endfor %}
</ul>
-->

<h2>Contact Me</h2>
<ul class="posts">
	<li>Electronically mail me: my first name at this domain</li>
	<li><a rel="me" href="https://mastodon.social/@AustinWise">Mastodon</a></li>
	<li><a rel="me" href="http://www.twitter.com/AustinWise">Twitter</a></li>
	<li><a rel="me" href="https://www.linkedin.com/in/austinwise">Linked-In</a></li>
	<li><a rel="me" href="https://bsky.app/profile/awise.us">Bluesky</a></li>
</ul>

<a href="/rss.xml"><img src="/images/feed-icon32x32.png">RSS Feed</a>
