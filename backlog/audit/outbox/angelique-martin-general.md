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
id: angelique-martin-general
title: Angelique Martin
interviewees:
- Angelique Martin
interviewer: Mike Hall
topic: software craftsmanship and practice
conference:
conference_year:
community: General
recorded_date: '2012-09-14'
tags: []
video_asset_id: angelique-martin-general

### RAW TRANSCRIPT
Hi, I'm Mike Hall with UGtastic. I'm standing here with Angelique Martin from 8thLight.
 She is, historically you've worked with the XP Universe and the, well the XP Agile Universe when it was rebranded because Agile was the thing.
 But now you're working with SCNA, Software craftsmanship North America. It's a conference that's been, what, this is our fourth year?
 Yes, it is our fourth year.
 Can you tell me a little bit about SCNA?
 So SCNA stands for Software craftsmanship North America. It's organized right here in Chicago.
 It will be held November 9th and 10th at the Aon Center.
 It's a two-day conference. We'll have about 14 speakers, including Robert Martin, Corey Foyle, and many other names that I can't think of right now.
 Oh, remember the roster, right now.
 Yes, Gary Bernard.
 There's two sets.
 Sarah, Sarah Ellen and Sarah Gray, Leon Gersing, I won't be able to remember the full team, Brian Marick, that I can quote, and I can't think of the other one, but it's all on the website.
 That's okay. You know, people can go to the site and see all of that information. But can you tell me a little bit about what is SCNA?
 So SCNA is a conference that aims at gathering people that care about their craftsmanship.
 They care about their craft. They care about improving themselves. They care about contributing to the community and meeting with their peers and hopefully exchanging and teaching each other.
 Okay. And this is what, you said the fourth year or so?
 Fourth year, correct.
 And traditionally, this was something that you shared responsibilities, 8th Light shared responsibilities with Optiva for you kind of handing it off back and forth.
 Right.
 And now this year, fortunately this year, that Optiva was acquired was an 8th Light year, so we're good this year, but...
 Correct. Well, Groupon Engineering was still very involved in the planning of 8th Light this year. As a matter of fact, they helped considerably to secure the program. So they're still a main sponsor and they're still very involved.
 Okay. That's good.
 The year before, when 8th Light was in charge of it, you did this kind of, you went, you know, one of the things I liked was you went beyond just the day-to-day.
 Like most conferences seem to be, okay, we have the conference, we have the sessions, we're going to maybe have an after party, but it's usually local, you know, or right inside of the facility where you organized like a field trip.
 Correct.
 Did you get any feedback from that from people?
 Well, I got some really positive feedback.
 The idea behind this was to take, you know, to have a, instead of a banquet where you would get a DJ and gigs really stand up and dance, we were going to take people out into buses so that they could network, have a chance to discuss the topics that the speakers had rushed on that day, for instance, and we celebrated different areas of Chicago.
 Yeah, well, that was one of the things is from people that had spoken.
 With me, from out of town, they were kind of saying that it was, it was, they were excited there was a chance to go and see things that they might not have known to go see, because I remember that this past year's SCNA, some of the people were kind of, from out of town, they were kind of floundering.
 That's, that's one of the hard things for introverts.
 Sometimes we will just go back to our hotel room and hack or stay local or not explore.
 Correct.
 You'll see the hotel room and the conference hotel.
 Yeah.
 Yeah.
 And so, I mean, the other thing was.
 You know, you were in the city one year, and then you're out near the airport.
 Was there any logistical things that made it more difficult being in the city or being outside of the city?
 I think that's primarily from the fact that one year, you know, we used to alternate.
 Tiva would organize, and then the next year we'd be in flight.
 And at the time, in flight was mostly located in the suburbs.
 So we had decided, and you know, for.
 For cost reasons as well, to take the conference outside of the city.
 It was the very first year that it was going to be a two-day conference.
 So to minimize the risk, we decided to take it out of the city.
 And we did it by the airport with a connection to the city within the parking garage of the hotel.
 Yeah.
 So it was easy to get out there.
 Correct.
 Okay.
 But cost was one of the big things you were saying.
 Yeah.
 You put events together.
 You know that.
 We don't do this for the money.
 Right, right, right.
 Yeah, but there's still a lot of money that changes hands, but mostly it's outgoing.
 Okay.
 Well, thank you very much for taking the time to speak with me, and looking forward to SCNA.
 Okay.
 Thank you.
