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
id: interview-with-anthony-zinni-and-jon-buda-and-shay-howe-general
title: Interview with Anthony Zinni and Jon Buda and Shay Howe
interviewees:
- Anthony Zinni
- Jon Buda
- Shay Howe
interviewer: Mike Hall
topic: developer community and conference conversations
conference:
conference_year:
community: General
recorded_date: '2022-01-07'
tags: []
video_asset_id: interview-with-anthony-zinni-and-jon-buda-and-shay-howe-general

### RAW TRANSCRIPT
Hi, I'm Mike. I'm sitting down here with the guys from Ref
resh Chicago, John, Shea, and Tony.
 Hi, guys. Thanks for sitting down with me today.
 The kind of question that we're going to get to is, can you
 tell me a little bit about Refresh Chicago,
 and what are you doing here, and what is Refresh?
 Certainly, yeah.
 Why is it Refresh?
 So, Refresh Chicago, we've been around for, I think, almost
 three years now?
 Two and a half.
 About that, two and a half?
 Yeah.
 And it's sort of, the Refresh group itself is sort of a
 loose collection of meetup groups around the country.
 It's not just here in Chicago.
 It's not just here in Chicago. It's around the country.
 They're not really affiliated with each other. They share a
 common name.
 But, I mean, the original goal was to be a way to meet up
 and sort of talk about these new ideas that were coming
 into web development,
 which was like a refresh.
 And it was like 10 years ago, when web standards were
 becoming a thing, and CSS was becoming more and more
 prevalent.
 So, we realized that there was sort of, there was no Ref
resh group in Chicago,
 and it was sort of, we're trying to fill this gap, which is
 bringing web designers and web developers together to sort
 of talk about common topics.
 Yeah, because we...
 You see a lot of tech, like hard tech, like, you know,
 there was the Java group, which was huge for all of us, .
NET group.
 But nothing really serving designer, UI guys.
 I mean, when you think about web design, it's...
 It is technical, and it's creative, and it's design, but it
's all of the things sort of together, right?
 And it's messy, too.
 Like, there's not one...
 Every web designer can tell you that they do something
 different.
 Some do code, some don't.
 Some don't.
 Some do a lot of UI, some don't.
 Yeah.
 And then, our group kind of fills that void.
 You know, it's not just, like, tech.
 It's not just creative.
 It's everything.
 And some weeks, it makes more sense to certain people, and
 some weeks, it makes more sense to others.
 But I think that's sort of the niche that we fill in
 Chicago.
 So, giving that you're kind of, like, trying to balance
 people who have maybe very different ways of defining what
 they do,
 do you have, like, a lot of flux between attendance?
 I think we're kind of lucky.
 I think our membership, I think it's at, like, 1,300 people
 or something now.
 So, we keep a steady number, but we're seeing different
 faces.
 There's the people who show up regularly, but we do see a
 lot of different faces coming,
 which I think is actually a benefit to the group, because
 you're going to meet new people every time when you come,
 which is something that's pretty unique to this group.
 And also, a lot of it depends on the speaker, too, right?
 Like, that speaker development heavy, we tend to get more
 of a go.
 A Rails crowd and development heavy, and then when we have,
 like, a designer come out, it's more of, like, a designer
 crowd.
 But there's always quite a bit of overlap, too.
 And our goal, I think our goal overall is to sort of have
 our members attend talks that they're not necessarily
 comfortable with,
 or, like, give them some experience in some area that they
 don't necessarily know about.
 Okay, and I know you guys have done some stuff with some of
 the startup.
 So, because I had associated the refresh with some of the
 entrepreneurial startup movements in Chicago.
 I think it's just, like, a natural side effect of the
 market that we touch.
 You know, in Chicago, it's kind of different than, like,
 the Valley,
 and it's kind of different than, like, New York in terms of
, like, startup culture or creative culture.
 And they're a lot more entwined here, I think.
 So, out of that, we get speakers who are naturally part of
 startups.
 And things of that nature.
 And it just kind of spawns out of that.
 So, it's kind of like a natural evolution for us.
 And so, kind of, what is your schedule for meetings?
 Is it monthly?
 Yeah, we meet the fourth Wednesday of every month right now
.
 And do you sponsor?
 Or how do you fund your group?
 I mean, we're here in the ITA.
 Yeah, so Groupon is one of our main sponsors.
 They basically sponsor food and drinks every month.
 DevMind helps us out.
 They're one of our good sponsors.
 They, sort of, kick in and help cover costs for, like, meet
up.com, domains, things like that.
 Just miscellaneous costs.
 ITA helps us out with the space.
 Okay, cool.
 And what are the plans for the future with your virtual?
 Are you looking forward at, like, Chicago Coke Camp that's
 coming up this month?
 But, you know, we've grown a few conferences out of some
 group environments.
 Are you guys looking forward?
 I mean, because I'm 1,300 members, you've got a large base.
 Yeah, we're looking to, we are actively partnering with
 another company to throw a conference in the fall.
 Like, a large web conference that covers the same sort of
 topics that we want to cover here.
 Yeah, it's the same general mix of just web craftsmanship.
 So we'll be involved with that.
 I don't know what we can say about that yet.
 We're not really announcing anything.
 We can say, we can say.
 You're working on it.
 We're working on it.
 Yeah, it is.
 Chicago Web Comp.
 So Deb and mine did it last year.
 Okay.
 This year we're teaming up with them to basically both
 partner on it and do it together.
 Okay, great.
 So I'll make sure and put that link into the show notes.
 Sounds good.
 Is there anything else you'd like to say about Refresh or
 the community?
 No?
 I would say if you haven't come out yet, come on out.
 I mean, it's a pretty welcoming group.
 It's not, you know, we don't focus on one topic, so.
 Yeah, and I'd say.
 I'd say, you know, if you want to talk in front of the
 group, that's always an awesome thing.
 Yeah, definitely.
 So we've been a little lucky lately, and we've got a great
 lineup started,
 but we definitely have room to fit people in in the future,
 too.
 So the more ideas, the better that we can share.
 Great.
 Well, thank you very much for sitting down with me.
 Yeah, thanks for having us.
 I look forward to the meeting.
 Thanks a lot.
