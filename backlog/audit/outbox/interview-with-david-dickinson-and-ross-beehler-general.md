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
id: interview-with-david-dickinson-and-ross-beehler-general
title: Interview with David Dickinson and Ross Beehler
interviewees:
- David Dickinson
- Ross Beehler
interviewer: Mike Hall
topic: developer community and conference conversations
conference:
conference_year:
community: General
recorded_date: '2022-01-07'
tags: []
video_asset_id: interview-with-david-dickinson-and-ross-beehler-general

### RAW TRANSCRIPT
Hi, I'm Mike. I'm sitting down here with Ross and David from South Bend Software
 Craftsmanship User Group. We're going to talk a little bit about the user group
 that they run and so can you just tell us a little bit about what you guys do
 with the South Bend User Group. Obviously it's in South Bend, but can you give a
 little bit more details? Sure, so I'll start with a little bit of history. We used to
 have a dinette user group that was dying and we decided that we needed to make a
 language agnostic, technology agnostic and we had a couple people going up to
 Chicago to their Software craftsmanship user group and we liked what we saw and
 we connected with some of the people there to get ideas and assistance and we
 just started the group in South Bend and we meet once every two
 months and a typical meeting is a speaker talks for a little while and
 then we just have open discussion afterwards with the speaker. If I had to
 give advice for for the smaller cities like South Bend, reach out to the
 Software craftsmanship community in a big city near you because Chicago has
 been instrumental in helping us. They've been sending out speakers like Uncle Bob
 and people from Teva Groupon and A-Flights interested in helping us out
 as well. So definitely look for help. There's plenty of people in the
 community that are willing to help. Yeah so like you said you go on a kind of a
 semi-monthly cycle. Why don't you guys go semi-monthly versus doing a
 monthly schedule that seems to be kind of a common pattern? I think part of it is like Russ mentioned, we were talking earlier just for the
 workload. Yeah. But I think that our goal would be to do it more often and we're
 moving towards having weekly meetings to begin moving to the Ruby world and I imagine there are a lot of people in the community that are willing to help.
 Yeah. I think part of it is like Russ mentioned, we were talking earlier just for the workload but I think that our goal would be to do it more often and we're moving towards having weekly meetings to begin moving to the Ruby world and I imagine there are a lot of people in the community that are willing to help.
 we do at least once a month with the whole team to do one of these speakers or something like that.
 So I'm curious, like you explicitly said Ruby, what is it about, why do you gravitate towards
 Ruby versus just any other? So our talent is primarily .NET, so it's just introducing diversity
 and a different school of thought and Ruby has kind of a community mindset anyways and so just
 to bring, find those who do know Ruby that we're not connecting with, bring those into into our
 group would also increase our sense of community as well. I think if the Microsoft guys are used
 to having a Microsoft-ish kind of community and we'd be able to move, it's harder to find the
 same sort of thing with PHP or Python, they're not as close-knit. We want to move out of a
 compiled language, I did anyway, move the team out of a compiled language into a dynamic language and
 just see what would happen there and Ruby's, you move into another place where there's already a
 home, there's a house they're built. Oh yeah, so it's, you have kind of a
 preconceived notion of the community that comes from kind of an established Microsoft
 developer base and you're looking at well where else could we go from that and looking at the
 Ruby community which has been really active, what are you saying that seems to be kind of appealing,
 like an easier transition because you kind of have an idea of where you're going to not kind of...
 Yeah, I'd like to stress that the Software craftsmanship group is technology agnostic,
 we still have speaking, our speakers talk about either soft skills or higher level themes,
 so but we also need to have the people get used to getting together and pair program and stuff like
 that and so we're using Ruby since it's a new language as an avenue to do that, so we're going
 to teach people Ruby, get them together and do contests together, learn how to do TDD and stuff
 like that, so it's, that's...
 This is the focus we're taking.
 And you know, we did have a little brief conversation before and we talked about how,
 you know, South Bend, you're kind of a, it's more of a residential community where people are
 commuting to and from South Bend, so you have a little bit of a challenge
 dealing with trying to get people in in the evenings or in the early mornings,
 you know, like what is your attendance of like when you're trying to do an evening meeting,
 does it usually seem to be
 overly impacted by the fact that people are commuting to South Bend versus working right there?
 Sure, since we meet once every two months, our meeting attendance is usually 30
 or so, which isn't bad, but for the more collaborative building type meetings that
 we have, like a Coke and Coffee, which Coke and Coffee is usually in the morning, which we have
 trouble getting people to come out, so for this Ruby exercise, we're gonna partake in here, we're
 gonna do it during lunch.
 Okay.
 So we'll just meet at a kind of a common place consistently once a week, and we think we'll get
 a lot better attendance at lunchtime.
 Yeah, yeah, lunches, having a family myself, I can attest to those midday breaks are a little
 bit easier to accommodate the schedule, yeah. Okay, well, you guys have a website, we'll be
 posting that along with the LinkedIn, well, what is the website?
 Actually, we have a LinkedIn group.
 Oh, you have a LinkedIn group?
 Yeah, but we are evaluating different methods.
 Okay, is it a public group that we'll be able to link to?
 Yes.
 Okay, great. All right, well, thank you very much, Ross and David,
 appreciate you sitting down with me.
 Thank you.
 Take care.
