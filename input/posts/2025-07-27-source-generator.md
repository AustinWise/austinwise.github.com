---
layout: post.liquid
title: Creating a C# source generator with AI coding agents
published_date: 2025-07-27 21:00:00 -0700
description: Reflections on building a simple greenfield project using AI coding agents.
---

Starting a programming project with a blank slate in an unfamiliar domain can feel daunting.
It can be hours and hundreds of lines of code before you have a program that does anything useful.
In this initial stage it can be hard to keep the motivation to grind through it or even get started,
particularly for side projects.

I have a side project like this that's been on my TODO list for a while.
I wanted to build a
[C# source generator](https://devblogs.microsoft.com/dotnet/introducing-c-source-generators/)
that would generate deserialization code for the [Sep CSV parser library](https://github.com/nietras/Sep/).
That is, it would take input like this:

```c#
partial class MyCsvRecord
{
    [CsvHeaderName("PersonName")]
    public required string Name { get; init; }

    [CsvHeaderName("Birthdate")]
    [CsvDateFormat("yyyy-MM-dd")]
    public DateOnly? Birthdate { get; set; }

    [GenerateCsvParser]
    public static partial IEnumerable<MyCsvRecord> ParseFile(SepReader reader, CancellationToken ct = default);
}
```

and generate output like this:

```c#
partial class MyCsvRecord
{
    public static partial IEnumerable<MyCsvRecord> ParseFile(SepReader reader, CancellationToken ct)
    {
        int NameNdx;
        int BirthdateNdx;

        if (!reader.Header.TryIndexOf("PersonName", out NameNdx))
        {
            throw new ArgumentException($"Missing required column 'PersonName' for required property 'Name'.");
        }
        if (!reader.Header.TryIndexOf("Birthdate", out BirthdateNdx))
        {
            BirthdateNdx = -1;
        }

        foreach (SepReader.Row row in reader)
        {
            ct.ThrowIfCancellationRequested();

            MyCsvRecord ret = new MyCsvRecord()
            {
                Name = row[NameNdx].Span.ToString()
            };
            if (BirthdateNdx != -1)
            {
                ret.Birthdate = DateOnly.ParseExact(row[BirthdateNdx].Span, "yyyy-MM-dd", CultureInfo.InvariantCulture);
            }
            yield return ret;
        }
    }
}
```

I initially started to write this source generator by hand. It was slow going.
I have never written a Source Generator before and the last time I touched the
[C# compiler API](https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/),
was at least 5 years ago.
I modeled my implementation after the
[Microsoft.Extensions.Logging source generator](https://github.com/dotnet/runtime/tree/ea721e7486615b95c8ede98a6f54aa5178d4c888/src/libraries/Microsoft.Extensions.Logging.Abstractions/gen).
This existing generator has a nice architecture, splitting the traversal of syntax trees from the
generation of code. Its input and output are similar to the goal of my source generator: one function
is generated for each annotated function.

I copy-pasted a few lines at a time and tweaked them to be about CSV parsing instead of logging.
This was painfully slow.
Eventually I realized that what I was doing was fairly
mechanical and could probably be accomplished using a coding AI agent.

After using a coding AI agent to create the initial implementation and iterate on the feature set,
I have published the result source generator on
[GitHub](https://github.com/AustinWise/SepCsvSourceGenerator)
and
[Nuget.org](https://www.nuget.org/packages/AWise.SepCsvSourceGenerator/).
It's working well enough now for some of my personal projects. Continue reading if you want to know
more about using AI agents to create a project in an unfamiliar domain.

## What is a coding AI agent?

An AI coding agent takes the traditional AI chatbot interface and adds the ability for the AI to read & write
files and execute commands. Further tools can be added using the
[Model Context Protocol](https://modelcontextprotocol.io/).

You give them a prompt and then they start proposing changes to files. You can approve every change
individually or just let them rip. Sometimes they will pause themselves to ask for clarification.
If they start going down a bad path you can interrupt them and further prompt them to correct
their direction.

See [this article by Thorsten Ball](https://ampcode.com/how-to-build-an-agent) that shows how to make
a simple AI coding agent. It's not much code. It's just a for loop that alternates between asking for
user input, generating text with a LLM, and doing tool calls.

## Tips on using agentic coding tools

I used [Gemini Code Assist](https://codeassist.google/), both in the form of the
[Gemini CLI](https://github.com/google-gemini/gemini-cli) and the
[Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=Google.geminicodeassist).
Here are some tips that I found useful while writing my C# source generator.

> **Disclosure:** My choice to use Gemini Code Assist in preference to other similar tools is partly
> driven by a desire to try out what other people at my company are working on.
> This post is solely my own opinion and does not represent the views of my employer.

### Specify context to get better generation results

Context can be the difference between having the LLM generate something mediocre or incorrect and the
LLM generating exactly what you want.

To start with, I create a [sample program](https://github.com/AustinWise/SepCsvSourceGenerator/blob/agentic/SampleCsvCode/Program.cs)
showing the expected input and output of the of my source generator. It took several iterations of this
sample program to get the agent to generate what I wanted.
This process reveled that I was not entirely clear about my intent with for the
generator. For example, the initial version was not clear on what would happen if a column was missing
from the CSV file. I added comments to the file and additional types of CSV columns to illustrate
what I wanted and why.

The [resulting code](https://github.com/AustinWise/SepCsvSourceGenerator/commit/9d2908b9eed7a75415c2fb06a502ad9155877354)
did the job, but was not very maintainable. It put everything into one big class.
The code lacked any diagnostics to inform users of the source generator when they incorrectly used
the code generator.

To give the LLM a guide on how to architect the source generator, I passed in the aforementioned
[Microsoft.Extensions.Logging source generator](https://github.com/dotnet/runtime/tree/ea721e7486615b95c8ede98a6f54aa5178d4c888/src/libraries/Microsoft.Extensions.Logging.Abstractions/gen),
code, telling it to do something similar. The
[resulting code](https://github.com/AustinWise/SepCsvSourceGenerator/commit/d08830c6721e46de31fcbfcac279a46c7ff573e6)
had the shape I desired, splitting the source generation logic between parsing the syntax trees and
emitting code.

### Tests are important as ever

Once I had the basic structure of the code and verified the source generator created the expected output,
I attempted to do some refactoring using the LLM. The LLM made changes that compiled but broke the output.
Without any tests to verify that what I was doing was doing, I was just vibe coding [^1].

By adding a test suite, the LLM could use test failures to drive its code generation and create something
that worked most of the time.

### Create tools and instructions to help the LLM

To ensure that the generated output of the source generator does not change unexpectedly, I
[added some snapshot tests](https://github.com/AustinWise/SepCsvSourceGenerator/commit/87936bc60e7f56cf383b9301d53725a51ce2f463).
The LLM was able to generally create and fix snapshot tests for the most part. But it really struggled
to get the whitespace perfect.

To keep the LLM from wasting time repeatedly tweaking white space, I added a script to regenerate
the snapshots and instructions in the
[GEMINI.md file](https://github.com/AustinWise/SepCsvSourceGenerator/blob/main/.gemini/GEMINI.md)
for when to do so.

To make sure the generated code is not garbage, these baseline tests make sure everything compiles
without warnings and I still check the snapshots each time they are changed. I also have it use a
code formatter to ensure consistent style.

### Watch out for the agent getting caught in an infinite loop

LLMs sometimes get stuck in an infinite loop where they repeatedly say the same thing.
There is a [known issue](https://github.com/google-gemini/gemini-cli/issues/1531) in Gemini CLI where
this problem presents as repeatedly trying to do the same thing.
For me it stuck repeatedly trying to adjust the whitespace in the
snap shot tests. I decided to let the agent cook, hoping it would get out of its rut.

I came back 30 minutes later and it had burned through 46 million tokens and $35.
It was no closer to getting the white space right.
There are other times the LLM can go down the wrong path.
So I don't leave the agent running autonomously for extended periods of time.

### You don't have to let the tool do everything

There have been several times where the tool generates something that mostly works, but is not quite.
Sometimes you can interject and add a message to correct its course.
Sometimes the code is close enough I can tweak it a bit to get it to do what I want.
Other times the tool totally misunderstands the prompt and I do a `git reset` and create a new prompt.
Some changes I don't quite know how to put into words succinctly and it's faster to just make the change.

Traditional refactoring tools can be a better fit for some changes.
You can use Visual Studio to remove a parameter from a method faster than you can write the prompt to
do so. Every reference to the method will be updated with 100% accuracy, while an LLM is
only probabilistically going to find all the references.

## Conclusion

The Gemini Code Assist agent was great for getting this project past the tedious initial phase of
going from an empty editor to the initial working generator. Just getting the prompt and sample code
right for the initial generation helped refine the design of this code generator.

Once I had the initial code base, I used a mix of traditional programming and prompting to add more
features and polish the codebase.
This process also highlights the continued importance of traditional software development tools. The
determinism and accuracy of tools like compilers and unit tests provide useful context to guide the
LLM's output and keep its proclivity to generate plausible but incorrect code in check.

I'm not sure what to feel about the future of programming with these tools.
Sometimes I feel sad that Gemini is having all the fun writing code.
Other times it's pretty cool to have it do tedious refactoring while I'm cooking dinner.
I'm also not sure how well this approach scales to maintaining a larger existing codebase, as everything
in this project was quite small and self-contained. The entire code base fits in the context window.

Whatever the future holds, I think the tool is useful even in its current form and I will be trying
it out with other projects.

## Footnotes

[^1]: [Vibe Coding](https://en.wikipedia.org/wiki/Vibe_coding) is a way of using AI coding agent tools where
      the human author completely surrenders their agency to the agent and lets it do whatever it wants.
      It might be fun, but it's not software engineering.
