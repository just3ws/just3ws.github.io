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
id: aaron-holbrook-general
title: Aaron Holbrook
interviewees:
- Aaron Holbrook
interviewer: Mike Hall
topic: community building and user-group organizing
conference:
conference_year:
community: General
recorded_date: '2013-04-26'
tags: []
video_asset_id: aaron-holbrook-general

### RAW TRANSCRIPT
Hi, it's Mike with UGtastic again. I'm sitting down with Aaron Holbrook who has started up a user group, a WordPress user group in McHenry County, Illinois.
 And he's also spoken at several of the WordCamps and he's actually getting ready to start up another WordPress-oriented conference.
 So, thanks Aaron for sitting down with me. So, what is the McHenry County WordPress Meetup?
 That's right, and thanks for having me, Mike. I really appreciate it.
 Yeah, so I started just recently, in the last couple months, McHenry County WordPress Meetup.
 So, basically, there was no user group, there was no really community out where I live, which is northwest suburb of Chicago, McHenry County.
 So, I decided to put one together.
 Okay, great. And why WordPress, though?
 I'm a big WordPress developer.
 I've been using WordPress since 2005.
 So, I'm pretty fanatical about it and it's about 95% of what I do.
 So, I'm really dedicated to WordPress and using it in my business and really giving back to the community and helping other people learn how to use it and answer their questions.
 And, you know, networking with the community, so people that are also interested in WordPress.
 Well, I think it's interesting because I've mostly approached WordPress as a...
 Just as a purely blogging platform, but what I was reading up a little bit before we spoke is that it's a lot more than just that.
 Yeah, it really took a turn in about 2009.
 Custom post types or content types were rolled out and it turned WordPress from a blogging platform really to a full-fledged CMS with a lot of really, really good features.
 Especially the client ease of use.
 The client ease of use and the ability for end users to be able to use it to maintain their site is really, really good.
 So, that's a really nice feature of WordPress.
 So, what kind of...
 What do you guys talk...
 What's your format for your meetup?
 Well, like I said, we just started a couple of months ago, so we've only had a couple.
 But it's been...
 We've had, you know, like open form with Q&A questions, you know, sessions where people just bring a list of questions.
 And we just kind of have some drinks and some pizza and dinner.
 And we just kind of talk about, you know, what can you do on WordPress?
 You know, what should...
 Hey, I'm a beginner.
 What should I do?
 Or, like, what plugins are good?
 We just...
 Our most recent, we actually had Heather Acton, who leads the Lake County WordPress meetup.
 And she's really, really smart.
 And she's got...
 She gave a whole lecture on, like, the best, you know, tips and practices for beginners.
 And, you know, like, what you should do when you first, like, get involved with your WordPress site.
 So, that was pretty good.
 Yeah, so...
 How's that?
 I know.
 That's perfect.
 Well, yeah, the...
 Sometimes this happens.
 I get tongue-tied.
 But what I was going to say is, as far as, like, how many...
 Have you been able to reach many people?
 How do you...
 I mean, is there a pretty vibrant WordPress online community?
 That you were able to reach out to?
 Or how do you...
 Yeah, there's actually...
 In and around Chicago, there is a really tight-knit group of WordPress contributors and community members.
 And I've since gone to WordCamp Chicago in 2010, I think it was.
 It was my first time.
 And...
 No, actually, I take that back.
 It was last year.
 Yeah, last year was the first time I had gone.
 2011.
 And I got to talking with the organizer, who, like I mentioned before, her name is Heather Acton.
 She was lead organizer last year.
 And I was wondering, because, like, I had applied to speak, and I didn't get accepted.
 So I went up to her and I asked why.
 And, you know, I was like, what can I do better to, you know, get an opportunity to speak at one of these?
 And so we got to talking, and it turned out I had Git in the title of my presentation.
 And that was...
 They weren't sure if they should use that because, you know, it wouldn't necessarily be neutral.
 So...
 But I got to talking with her, and I met a great bunch of people.
 And, yeah, it was...
 I'm sorry.
 Going back to the question, I got lost.
 Oh, I'm lost, too, now.
 That's okay.
 That happens sometimes.
 No, I was...
 Mostly I was asking about how did you reach the people that were...
 Oh, right, right.
 Did you go online or...?
 Actually, meetup.com did a spectacular job of just letting people know, like, if they were looking for something like that.
 So I didn't do a heck of a lot of...
 I didn't do any marketing.
 I just kind of told people, and then when I went to the WordCamps, I let people know.
 But, yeah, meetup.com did a great job of...
 People just started showing up.
 I put it out there, and then people just started showing up to it.
 I think you asked also...
 Sorry about the long tangent.
 You asked about how, I think, big my group is.
 Right, right.
 Or, like, how active it is.
 I think we have about 50 people signed up in the group, but really it varies between, like, 10 and 15 people show up in person.
 Oh, that's pretty good.
 So, I mean, that's...
 Especially as far out...
 I'm also from the same neck of the woods as you, so I know how hard it is.
 How hard it is to get people out to meetings.
 I used to run a group called Software craftsmanship in McHenry County, which is kind of just a little bit up the road from where you're at.
 It's very much a software-oriented group, but that's another thing.
 It's, like, it's the focus of your group on how to use and administer WordPress, or is it how to develop plug-ins, you know, PHP and all that?
 From what I found, like, I'm more of a higher-level developer.
 So, you know, I'm talking about version control and, you know, things that are way past beginners.
 And I would love to do more talks like that, but unfortunately...
 Well, I mean, it is what it is.
 Like, a lot of people are just learning about WordPress, so we have a lot of beginners, which is fine.
 Like, that's totally fine.
 We just have to gear the content and the topics more towards that.
 So, yeah, there's more.
 I would love to get more of the developers, like you and me, you know, people out to some of these, because I think not only could they help contribute, but I would love to meet, you know, more developers.
 Well, I can personally say that the SCMC group is looking to move their blog, and they could certainly use some help with getting off of Posterous.
 Well, give me a call.
 All right, great.
 Well, thank you very much for taking the time to sit down with me.
 Really appreciate it.
 No problem.
 Thanks for having me, Mike.
