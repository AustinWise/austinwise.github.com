--- 
layout: post.liquid
title: Lazy Loading Collection
published_date: 2009-01-26 16:50:00 -0800
permalink: /{{year}}/{{month}}/{{day}}/{{slug}}{{ext}}
---

So I came across an interesting situation in a program I was writing recently.  I had a bit of code that takes a list of image URLs to download and display.  It shows the UI immediately while it downloads more pictures in the background.  However in some cases each URL needs to be transformed a bit and each transform required another web request.  If I did all the transforms before starting to download the first image there would be a large pause before anything could be shown to the user.

Fortunately, my image download and display code took an ICollection&lt;Uri&gt; interface instead of a concrete type.  So I made a little collection that would lazy load the transformations.  Now no matter how many untransformed images there are, it will always take about the same amount of time for the first image to be shown to a user.

My collection ended up being not specific to this program.  You can <a href="https://github.com/AustinWise/austin/blob/8b93d0cd1cbabd6d0120734af8568d15996cb155/Austin/Collections/LazyCollection.cs">take a look at the code on GitHub</a>.  Just a heads up: there are several methods that are not supported because I did not need them and they would be difficult to implement.  For example, how do you implement Contains when not all the transformations are complete?
