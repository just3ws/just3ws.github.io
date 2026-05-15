### SYSTEM ROLE & INSTRUCTIONS
      ### SYSTEM ROLE: ARCHIVE FORENSIC AGENT
      You are a Staff-level Software Engineer and Oral Historian. You are repairing "phonetic-heavy" transcripts from 2010-2015 era technical interviews.

      ### DOMAIN CONTEXT
      The archive covers the "Software Craftsmanship" movement. You must be hypersensitive to:
      - Ecosystems: Ruby on Rails, Java (Spring/Hibernate), .NET (C#), Clojure, Smalltalk.
      - Patterns: TDD, SOLID, Active Record vs Data Mapper, DDD, Hexagonal Architecture.
      - Events: SCNA (Software Craftsmanship North America), GOTO, WindyCityRails.

      ### HEAVY-LIFTING RULES
      1. INFER SPEAKERS VIA SEMANTIC ROLE:
         - M1 (Mike Hall): Asks about community, "why did you build this?", "what was the impetus?", and provides meta-commentary on the recording environment.
         - S1 (Subject): Provides deep technical rationale, implementation details, and mentions specific library names they authored.
      2. JARGON CORRECTION (PHONETIC REPAIR):
         - Correct "phonetic drift" based on technical context. 
         - Examples: "Active JSBC" -> "ActiveJDBC", "Postgre" -> "Postgres", "Hibernate" -> "Hibernate", "A-gile" -> "Agile".
      3. TURN SEGMENTATION:
         - Identify "back-channeling" (e.g., "Right", "Yeah", "Okay") and keep them as distinct turns or merge them into the previous speaker's block only if they do not interrupt the flow.
      4. INSIGHT EXTRACTION:
         - Identify "Durable Insights": Concepts that are still relevant to Staff-level engineering today.
         - Identify "Time-Bound Constraints": Decisions made because of the limitations of the era (e.g., "waiting for Oracle drivers in 2007").

      ### OUTPUT SCHEMA (STRICT YAML)
      You must output a YAML object containing:
      - speaker_map: Map of ID (M1, S1) to Full Name and Role.
      - turns: Array of {speaker: string, text: string}.
      - insights: Array of {statement: string, type: durable|time-bound, confidence: high|medium}.
      - youtube:
          title: "SEO-optimized title using interview context"
          description: "Full YouTube-ready description including summary, speakers, and event context."
          tags: ["array", "of", "SEO", "tags"]
          chapters:
            - timestamp: "00:00"
              title: "Introduction"
            - timestamp: "MM:SS"
              title: "Chapter Title"

      Do not output any prose, markers, or backticks outside the YAML.

### INTERVIEW METADATA
---
id: interview-with-dan-north-general
title: Interview with Dan North
interviewees:
- Dan North
interviewer: Mike Hall
topic: developer community and conference conversations
conference:
conference_year:
community: General
recorded_date: '2022-01-07'
tags: []
video_asset_id: interview-with-dan-north-general

### RAW TRANSCRIPT
Hi, it's Mike again with Ute Tastic. I'm still here at GoToCom Chicago, they haven't kicked me out yet.
 I'm sitting down with Dan North. Dan is known as the kind of the father of BDD.
 You are the one who wrote the first paper and description and first implementations.
 And I also think it's fascinating that you're kind of an iconoclast who likes to question dogma.
 Over the years, over the last seven years, BDD has become dogma.
 Either you do it or you don't. And you can't do BDD, TDD, you gotta do BDD.
 And there's all these things, and being that you're a person who questions dogma,
 what is it like to be someone who created something who's now been accepted as a dogmatic thing?
 As a dogma, I think, yeah. So this to me comes down to experience.
 So what happens is when you have someone who is new to something,
 when they're a novice in a particular area, they want to just find a thing that works.
 They want to be told what to do, they want rules, they want structure,
 and they want to be able to just follow a recipe, and they want to get quick wins in that way.
 This is sort of part of learning theory is that this is how we operate while we gain context and while we gain experience.
 And once we've got a bunch of experience and a bunch of context, we can start making good decisions.
 Now, what happens is people will pick up something without any context and say,
 "Right, well then this must be how it works." And they're really uncomfortable, as I was talking about, with uncertainty.
 They don't like the idea of uncertainty. They don't like the idea that we can't know some things.
 And so they'll fill in the blanks. And this is what we do.
 I've deliberately never written down. I mean, I wrote the Introducing Beauty article,
 but I've never really been that descriptive or prescriptive about what it is and what it isn't.
 Because to me, it isn't a set of practices. It's a way of engaging. It's a way of trying to get work done.
 Yeah, it's a way of thinking about a problem.
 Yeah. And Liz Keogh says this really well. She says basically it's about the conversations.
 Everything comes back to the conversations.
 And so I said in a talk recently, the only BDD tool that matters is the one in your head.
 But that's it. Everything else is just detail.
 And so you get the camps that are the aspect camps and the JBehave camps and the cucumber camps and all these guys.
 And then this world of misinformation about BDD is this and BDD is that.
 And BDD only works at this high level. And then you use TDD down in the whatever.
 And all that is a basic misunderstanding of what TDD is and what I was trying to do with BDD and where that's ended up.
 So I think with anything, as soon as it's around for any length of time, people will become dogmatic about it.
 There's a subset of people. There's a type of people, if you like, who are going to pick up on something.
 And especially when they start making that their thing.
 I'm a BDD consultant. And they've got to sound pretty definite about things.
 This is BDD and this isn't BDD.
 This is why you should listen to me.
 Yeah, this is why you should listen to me. This is why you should pay me bucks.
 Right.
 So I have a working theory. It's only a theory. I have no data.
 It's only observational.
 Which is that people start selling certifications in things.
 Well, like any of those things.
 When they think it's the last good idea they're going to have.
 So there's a...
 I'm going to monetize this thing.
 Now, I never wanted to monetize BDD because I don't think it's a...
 It's just a useful thing.
 It's a useful thing. You shouldn't monetize ideas.
 That's crazy. Or rather, you shouldn't try to lock down ideas.
 I came across a lovely quote.
 If you want an idea to travel, you shouldn't try and travel with it.
 Oh, okay.
 And I really like that.
 Don't assign it to your personality.
 No. No, very much so.
 Here you go.
 So I put it out there.
 So BDD started as me trying to coach TDD better because TDD is so awesome.
 I love TDD. I love the thinking that goes in TDD.
 You've heard me bashing on TDD.
 Right.
 I'm not. I'm bashing on TDD zealous because I'm bashing on zealous.
 Right.
 Do you know what I mean?
 It's not TDD.
 TDD is a pattern.
 Right.
 Okay.
 It isn't in the classic Alexandrian sense of a pattern.
 It's a strategy that works well in a particular situation in a certain context.
 It resolves some forces.
 It introduces other forces.
 And it needs to be used in conjunction with a bunch of other patterns.
 So there are places where it's the first thing I'll reach for is TDD.
 Right.
 There are other places where it's just going to slow me down or it's going to be irrelevant or it's even going to lead me to a wrong solution.
 Mm-hmm.
 You know.
 So when people say, "Oh, Dan North is in on TDD."
 That's...
 That's...
 It almost sounds like that dogma trying to find a conflict where it really isn't.
 Yeah.
 Yeah.
 It's making up a phantom enemy.
 And that's part of it.
 But I think part of it as well is it makes a good sound bite.
 Yeah.
 You know.
 Dan North is advocating copying and pasting code.
 Right.
 I am.
 Right?
 Yeah.
 There's a certain context in which I want to copy and paste code.
 Mm-hmm.
 And the context is very specific.
 And I describe it.
 It's one of my accelerated agile patterns called Ginger Cake.
 And the point about it is it's a pattern.
 It works in a certain context.
 That doesn't say you should always copy and paste code or you should never copy and paste
 code.
 It says, "Given these constraints in this environment, in this context, it's a useful
 strategy to have in your pocket."
 Yeah.
 Yeah.
 And that it's...
 That when...
 It's towards that level of mastery where I wonder if part of the dogma is people just
 don't feel confident enough also that there's...
 One second.
 I'm going to take a step back.
 Okay.
 And I want to just go back to what you were talking about with the last idea.
 I've heard that the reason that they want to charge money for it is because they think
 it's going to be the last idea they...
 Mm-hmm.
 But I've heard that in...
 With music as well.
 I've heard it as an argument why...
 Is that right?
 That's how many songs does an artist have in them?
 And if they don't charge for them, how do they know that they're going to have another
 hit?
 And if they don't protect their copyright, how do they know they're going to...
 Oh, okay.
 So, right.
 So, it's them thinking, "I've got a hit here, so I need to..."
 Yeah.
 Yeah.
 Okay.
 I like that.
 Yeah.
 Yeah.
 Yeah.
 So, that was...
 Yeah.
 Yeah.
 Yeah.
 Yeah.
 So, that was...
 It sounds like it's a human way of thinking about problems.
 It isn't unique to software development.
 It's just humans do this when we're confronted with the fear of, "This is all I've got."
 Yeah.
 Yeah.
 Maybe it's...
 Yeah.
 Linda Rising was talking about this yesterday.
 Lost aversion.
 Okay.
 So, the idea that you have a thing and you might lose the thing is much more compelling
 than...
 So, she was talking about reward structures and she said, "If you offer someone a bonus
 for doing something..."
 Yeah.
 Yeah.
 Yeah.
 "If you offer someone a bonus for doing something, it ends up being a disincentive."
 All the data says it ends up being a disincentive.
 Is that the Dan Pink's Drive?
 I think it's...
 Oh, there's a ton of...
 Yeah.
 There's a ton of research around this.
 Okay.
 He's one of them, certainly.
 Yeah.
 And the whole sort of behavioral economics school.
 Yeah.
 But that if you present it as, "I've already given you this bonus, but you'll lose it
 if you don't reach these targets," people will work extra hard to hit those targets.
 Okay.
 So, it's not that it's a carrot.
 Even though it's hypothetical.
 It's, "Here's your carrot, Bob.
 Take it away."
 Yeah.
 Yeah.
 Yeah.
 Yeah.
 Yeah.
 It's the risk of losing a carrot is more effective than a carrot...
 Yeah.
 ...or a stick...
 Yeah.
 ...is to offer the carrot as a thing that you could lose.
 I can see how that is.
 Because I can be like, "I have this carrot.
 We're going to take it away."
 Versus, "I don't have a carrot.
 I don't lose anything, but I might work all the way up to the line and not get it."
 I have to say, even what you described is, I've seen these bonuses at companies where
 now when a company says, "We're going to offer a bonus to you.
 We're going to offer a bonus to you for performance."
 I've been in enough companies where all of a sudden at bonus time, it was, "We weren't
 doing so hot last year."
 Yeah.
 Wow.
 Yeah.
 It's been a tough year.
 Yeah.
 Yeah.
 We're going to have to pull that belt a little bit tighter.
 Just see my new boat?
 Yeah.
 Yeah.
 Right.
 Yeah.
 Yeah.
 Yeah.
 And people will leave.
 I mean, you'll actually lose people by doing that because of the loss.
 They've now lost that thing and they're like, "Great.
 I nearly had that thing and I lost it."
 Right.
 So, it reminds me of...
 There's a great interview with Alanis Morissette.
 Yeah.
 Yeah.
 Randomly in one of the music magazines. And it was about her second album. So her first album was angry, angry music.
 And then her second album, she's met this guy and she's really in love and she's really happy and it's this album of happy songs.
 Things have gotten much better since the first album.
 It's a good album, there's some solid songs on there, but it's a happy album. And they were saying like all your fans are really furious because you're not writing this angry music.
 And she's like I don't write angry music, I write music about how I'm feeling. I was angry, so I wrote angry music. I'm happy as I'm writing happy music.
 I like to cut myself to the first album, but it just doesn't work.
 Yeah, exactly. And it's like I'm a fan of yours and I want you to carry on being angry because that's what I associate with you.
 And you get, in our industry I think there's something about that as well. There's a cult of personality thing where you associate someone with something.
 And that can become a reinforcing loop.
 Yeah.
 And there's folks, certainly in the kind of agile end of the industry, who do do one thing and they do the one thing again and again and again and again.
 And it's like well, you know, are you stuck there? Like move that thing forward. That thing was great. It was a great solution for the problem you had in that context.
 What's the new context? How does that move forward?
 Someone who's the antithesis of that is someone like Michael Feathers, who's always, always on something new.
 He's always like, he's always, brain's always going, he's always coming up with ideas.
 You know, he wrote this book about legacy code, you know, about 100 years ago, which is still a classic and still deserves a place on every programmer's bookshelf.
 And he's just doing crazy, crazy other stuff now.
 Right.
 And he's looking at how code bases evolve over time and all this.
 And he's, you know, every time I see him speak, it's fascinating. It's new. It's, you know, it's taking ideas forward.
 And so there are folks who, you know, the only association I have with Michael is it's going to work.
 It's going to be interesting.
 Right.
 Do you know what I mean?
 I know what you're trying to talk about, but it's going to be interesting.
 And it's the, I call it the noun problem.
 Once you get a noun as your middle name that says, like, you know, you're the legacy code guy or you're the BDD guy, then you're kind of like, well, yeah, I'm doing other stuff as well.
 BDD was one step on that journey.
 And also, if you look at it as a little ecosystem, there's, I'm not where the action is.
 Right.
 Right.
 There's the specification by example.
 You look at Liz Keogh with the BDD for life stuff.
 You look at Chris Matts and Aleph Marson with the real options.
 And, like, all of these things are kind of going off in really interesting, crazy directions.
 Yeah.
 And I'm looking at that going, wow.
 Do you know what I mean?
 I'm really enjoying seeing that evolve.
 From the other side of it, as somebody who's, I remember reading your post about BDD back, you know, in '06 or '07.
 And I was doing .NET at the time.
 And I remember just, you know, being like, oh.
 This is, you know, this is really great and wanting to figure out how to do this in .NET because it hadn't been defined yet.
 But I can understand that urge to want to look at the first person, you know, the first person who initiated it.
 And maybe not necessarily trusting those that came after.
 And when you're looking and you're trying to figure out what this thing is and you're trying to understand and get something in your mind, that I can remember continually going back to your blog and trying to get more information out of it.
 Yeah.
 I need to blog more.
 I need to write more.
 I love blogs.
 It goes to the cult of personality thing.
 Yeah.
 Where instead of me just thinking about the idea and saying how do we talk about this idea, it was more of, well, how do I understand more about what that person was trying to say?
 And then it becomes, well, so I could see how that thought process can evolve in people who are looking at these ideas.
 Well, and this is why I name drop as furiously as I do.
 Yeah.
 Is what I want is that we're going to have a culture of people who are looking at these ideas.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
 And I think that's what I'm trying to do.
