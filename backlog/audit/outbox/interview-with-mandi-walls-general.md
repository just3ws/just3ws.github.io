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
id: interview-with-mandi-walls-general
title: Interview with Mandi Walls
interviewees:
- Mandi Walls
interviewer: Mike Hall
topic: developer community and conference conversations
conference:
conference_year:
community: General
recorded_date: '2022-01-07'
tags: []
video_asset_id: interview-with-mandi-walls-general

### RAW TRANSCRIPT
Hi, it's Mike again with Ugetastic. I'm sitting down today with Mandy Walls who's a technical
 evangelist with OpsCode, the Chef people if you've ever done any kind of building servers
 or managing using the Chef utility, it's OpsCode. Hi Mandy, thanks for taking the time to sit down
 with me today. Kind of just want to ask you straight off, what exactly is a technical evangelist and
 how do you work with the technical community? Do you run conferences or do you work with people at
 conferences? Do you speak or how does that work? What is that? So originally our technical
 evangelist positions were folks who basically help our customers and our would-be customers like
 understand the technical needs of the customers and the technical needs of the customers. So we're
 working with them to help them understand what Chef does, what it is, how it can help you manage
 all of your systems. Over time and as OpsCode has grown, we're actually now the OpsCode's
 professional services team. So technically I'm really a consultant and I get to travel to our
 customers as they need help. We do training. I go to conferences representing OpsCode. So
 sometimes like in a booth or at a table passing out literature, sometimes giving talks about our
 product. We run our own conference. So that was the other part of your question. We are, OpsCode does
 run a user conference in college, ChefConf. And that's actually this year taking place in April. And so we put
 that together as a forum for our bigger customers who, well for anybody really, but as a place for folks to share
 things they've learned about.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So I'm really excited about that. I think it's going to be a lot of fun. I think it's going to be a lot of fun.
 So my interest in that goes back a number of years. For one thing, I've always worked in operations, and when we think about diversity in the technical community at large, some areas, some niches have better diversity than others.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So a couple times I've been to conferences related to maybe database technologies or programming languages, and the diversity is a lot more broad.
 So I think that's work-life balance and all kinds of stuff for technologists. It's really good.
 Oh, cool. Well, thank you for taking the time to sit down with me today.
 Absolutely. Thanks for inviting me.
