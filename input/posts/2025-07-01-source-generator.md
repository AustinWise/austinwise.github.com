---
layout: post.liquid
title: Creating a C# source generator with AI agents
published_date: 2025-07-01 16:00:00 -0700
---

There are times where I want to write a computer program and it all comes spilling out. It is as if
I have a rock and inside is a statue; I'm just chiseling around the statue to reveal it. I had that
sort of feeling creating my [US federal tax calculator](https://github.com/AustinWise/TaxStuff/).
I suppose this feeling comes when I have a clear vision for what I want to build and familiarly with
all the tools and techniques. In this case the techniques were using [ANTLR](https://www.antlr.org/)
to create a parser and and XML for creating file formats.

Other times it's hard to get started, even on when I have a clear goal in mind. For example recently
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

I have never written a C# source generator before, so it was slow going. I had never used the
[Roslyn API](https://learn.microsoft.com/en-us/dotnet/csharp/roslyn-sdk/)
to extract out the information I needed from all the syntax trees. I modeled my implementation after the
[Microsoft.Extensions.Logging source generator](https://github.com/dotnet/runtime/tree/ea721e7486615b95c8ede98a6f54aa5178d4c888/src/libraries/Microsoft.Extensions.Logging.Abstractions/gen),
copy-pasting snippets and tweaking them. Eventually I realized that what I was doing was almost
entirely mechanical and could probably be accomplished using a coding AI agent.

I have published the result source generator on
[Github](https://github.com/AustinWise/SepCsvSourceGenerator)
and
[Nuget.org](https://www.nuget.org/packages/AWise.SepCsvSourceGenerator/).
It's working well enough now for some of my personal projects. Continue reading if you want to know
more about using AI agents to create a project in an unfamiliar domain.

## What is an coding AI agent

> **Disclaimer:** While I currently do work within Google, this post is solely my own opinion and does not
> represent the views of my employer. I'm going to make up my own definition of an AI agent.

The definition of the term "AI agent" is at times nebulous. I've heard people talk about how AI agents
are going to trivially solve a problem; described using the same sort of hand-waving and magical thinking
that pervaded discussions about things like "blockchain" and "web3" a few years ago. There definitions
like [this one](https://cloud.google.com/discover/what-are-ai-agents?hl=en) from Google Cloud that
gets at the "what" but not so much the "how":

> AI agents are software systems that use AI to pursue goals and complete tasks on behalf of users.

I like to conceive of an AI agent as a state machine that uses a large language model to drive some
of the decision making for how it moves through states. Typically they use tool calling to cause some
effect in the work (writing a file) or to get more context (reading a file). Besides using the normal
mechanism of a state machine to guide their actions, they may also fill their context window with the
past inputs and outputs of the LLM. This acts as a "memory" to guide future interactions.

An AI coding agent is a special case of an AI agent. The goal is to translate a high level intent (add a new feature)
into a series of actions to accomplish this. The state machine is roughly:

![State machine of a coding agent](/images/SepCsvSourceGenerator/ai-agent.svg)

See [this article by Thorsten Ball](https://ampcode.com/how-to-build-an-agent) that shows how to make
your llm coding agent. It's not much code. It's just a for loop that alternates between asking for
user input, generating text with a LLM, and doing tool calls (reading and writing files).

## Tips on using agentic coding tools

I used [Gemini Code Assist](https://codeassist.google/), both in the form of the
[Gemini CLI](https://github.com/google-gemini/gemini-cli) and the
[Visual Studio Code extension](https://marketplace.visualstudio.com/items?itemName=Google.geminicodeassist).
Here are some tips that I found useful while writing my C# source generator.

### Specify context to get better generation results

Context can make the difference between having the LLM generate something mediocre or incorrect and the
LLM generating exactly what you want.

To start with, I create a [sample program](https://github.com/AustinWise/SepCsvSourceGenerator/blob/agentic/SampleCsvCode/Program.cs)
showing the expected input and output of the of my source generator. Iterated on this program and my
prompt several times. This process reveled that I was not entirely clear about my intent with for the
generator. For example, the initial version was not clear on what would happen if a column was missing
from the CSV file. I added comments to the file and additional cases type of CSV columns to illustrate
what I wanted and why.

The [resulting code](https://github.com/AustinWise/SepCsvSourceGenerator/commit/9d2908b9eed7a75415c2fb06a502ad9155877354)
did the job, but was not very maintainable. It put everything into one big class.

To give the LLM an a guide on how to architect the source generator, I passed in the aformention
[Microsoft.Extensions.Logging source generator](https://github.com/dotnet/runtime/tree/ea721e7486615b95c8ede98a6f54aa5178d4c888/src/libraries/Microsoft.Extensions.Logging.Abstractions/gen),
code, telling it to do something similar. The
[resulting code](https://github.com/AustinWise/SepCsvSourceGenerator/commit/d08830c6721e46de31fcbfcac279a46c7ff573e6)
had the shape I desired, splitting the source generation logic between parsing the syntax trees and
emitting code.

### Add tests

One I had the basic structure of the code and verified the source generator crated the expected output,
I attempted to do some refactoring using the LLM. The LLM made changes that compiled but broke the output.
Without any tests to verify that what I was doing was doing, I was just vibe coding [^1].

By adding a test suite, the LLM could use test failures to drive its code generation and create something
that worked most of the time.

### Create tools and instructions to help the LLM

To ensure that the generated output of the source generator does not change unexpected, I
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

### Infinite loops

There is a [know issue](https://github.com/google-gemini/gemini-cli/issues/1531) where the agent can
get stuck in an infinite loop. For me it stuck repeatedly trying to adjust the whitespace in the
snap shot tests. I decided to let the agent cook, hoping it would get out of its rut.

46 million tokens and $35 later, it was no closer. There are other times the LLM can go down the wrong
path. So personally I don't leave it unattended for to long.

### You don't have to let the tool do everything

There have been several times where the tool generates something that is mostly works, but is not quite.
I'll stop the tool and either tweak the code by hand or do a `git revert` and adjust the prompt.

For example, its initial approach for compiling and running the source generator was overwrought.
It create a big string with a test program, compiled the code, saved it to disk, dynamically loaded
the code, used reflection to invoked it, and then used the `dynamic` keyword to refer to access properties.
This worked, but it was a lot of moving parts that could break in ways that would be hard for either
a LLM or human to fix.

Instead I tweaked the
[test cases](https://github.com/AustinWise/SepCsvSourceGenerator/blob/0cc94df9b1f8d08c268132465fc88506250774dd/tests/SepCsvSourceGenerator.Analyzer.Tests/RunGeneratedParserTests.cs)
to declare all the types within the test assembly, so that you get compile errors on those earlier.
The source generator also runs with the build of the test assembly. Thus all the test code and generated
code can be easily referenced by the test cases, making it easier to spot what went wrong when there is
a typo in a property name.

## Conclusion

The Gemini Code Assist agent was great for getting this project past the tedious initial phase of
going from an empty editor to the initial working generator. Just getting the prompt and sample code
right for the initial generation helped refine the design of this code generator.

Once I had the initial code base, I used a mix of traditional programming and prompting to add more
features and polish the codebase. Adding a failing unit test and having Gemini fixed it worked well.
Other types of refactoring were more amenable to traditional refactoring tools. For example, removing
a parameter from method is something that Visual Studio can do with 100% accuracy, while an LLM is
only probabilistically going to find all the references.

This process also highlights the continued importance of traditional software development tools. The
determinism and accuracy of tools like compilers and unit tests provide useful context to guide the
LLM's output and keep its proclivity to generate plausible but incorrect code in check.

## Footnotes

[^1]: I stuck this at the end, because this is a pet peeve of mine that is not wholly germane to this post.
      [Vibe Coding](https://en.wikipedia.org/wiki/Vibe_coding)
