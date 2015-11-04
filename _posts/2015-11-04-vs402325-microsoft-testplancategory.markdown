---
name: vs402325-microsoft-testplancategory
title: VS402325: Work item type category Microsoft.TestPlanCategory does not exist in project
layout: post
time: 2015-11-04 15:00:00 -08:00
---

I tried to create a Test Plan on our Team Foundation Server today but I
got this error message:

    VS402325: Work item type category Microsoft.TestPlanCategory does not exist in project xxx

I solved this this by following the directions in this [MSDN article]
to enable the Test Plan feature on the project.

There were no search results at the time of writing about this error
message, I thought I may as well post one.

[MSDN article]: https://msdn.microsoft.com/Library/vs/alm/work/customize/configure-features-after-upgrade
