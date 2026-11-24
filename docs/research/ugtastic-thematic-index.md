# UGtastic Archival Evidence Index: The Voices of the Craftsmanship Era

## Overview & Archival Context

This thematic index mines the primary-source transcripts of the **UGtastic** oral history archive (recorded between 2011 and 2015 by Mike Hall across Software Craftsmanship North America, RailsConf, WindyCityRails, GOTO Chicago, and regional user group gatherings). 

These transcripts capture the living, unfiltered voice of working software engineers in the middle of a historic turning point: the rebellion against vendor-prescribed enterprise defaults, the emergence of the Software Craftsmanship movement following the March 6, 2009 Manifesto, the establishment of developer-led third spaces, and the disciplined pursuit of software quality through test-driven feedback loops.

Every entry in this index provides:
- **Verbatim Quote**: Transcribed firsthand speech preserving the speaker's exact cadence and vocabulary.
- **Speaker & Canonical Role**: Full practitioner identification.
- **Historical Event & Date**: Precise location and gathering context.
- **Repository Source File**: Exact path within the local repository corpus.
- **Thematic Analysis**: Connection to the four core pillars of *The Sound Above*.

---

## Theme 1: Professional Agency and Anti-Dogma

### Rejecting Vendor Ceilings, Corporate Cargo-Culting, and Top-Down Methodology Theater

The foundational impulse of both ALT.NET and Software Craftsmanship was the reclamation of technical agency from corporate monopolies and certified enterprise processes. Developers refused to accept that the boundaries of their engineering craft were set by Microsoft manuals, commercial tool suites, or project management certifications.

```
Quote 1.1: Breaking the Enterprise Monoculture
```
> "It is very hard to define what Alt.NET is. I am not going to dare try to define it... But I can give a few traits that could more or less describe the group. So I think we are mostly developers that are going after the continuous improvement and improvement of self or processes and also the quality of the software that you write. We like to think we are not necessarily .NET developers, but we are developers that happen to use .NET a lot. Probably like .NET a lot. And I think we try to also give a little bit of a voice to things that are good practices, good components, good methodologies that may or may not come from Microsoft. It may or may not even be .NET necessarily. So we try to give space for those things to be talked about...
>
> .NET developers are a funny type of developers. I mean, they have grown up being told what tools to use, how to do things, mostly by Microsoft. It kind of comes with the territory. I mean, .NET is a popular platform in businesses and enterprise, and it kind of comes with the kind of developers that you end up having in .NET. And so, there are not a lot of .NET speakers that are into non-Microsoft things. Some are, but they do not talk about it. There are no venues for them to talk about it. So, one way to change that, we believe it is one of the charters of our group, is to create more speakers within the community. And so, we really try to get our members to be encouraged to present on topics. And how often are you going to find a .NET user group that will invite you to talk about NHibernate? Or Castle Windsor? Or IronRuby?"

- **Speaker**: Sergio Pereira (Co-Founder & Organizer, Chicago Alt.NET; Signatory #592 of the Software Craftsmanship Manifesto)
- **Event / Context**: Software Craftsmanship North America (SCNA), Swissôtel, Chicago, IL (November 19, 2011)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011.yml`
- **Relevance to The Sound Above**: Demonstrates how practitioner communities actively resisted the passive consumption of corporate software tools. Alt.NET was not anti-Microsoft; it was pro-agency, pulling cross-platform ideas (open-source ORMs, dynamic languages, dependency injection) into an enterprise ecosystem that had been conditioned to wait for official permission.

```
Quote 1.2: The Trap of Default Toolkits
```
> "I remember once we ran a hands-on session and then went to the pub. A guy came up and said, 'I found this session today very easy.' I said to him, 'The session was not easy. You made it easy for yourself because you used your default toolkit. There is always something you can be a beginner at. Challenge yourself. There is always a structure there for you to do whatever you want... If you have done Conway's Game of Life 100 times in Java, start doing it in Clojure. Push yourself. I always say that to people.'"

- **Speaker**: Sandro Mancuso (Founder, London Software Craftsmanship Community; Author of *The Software Craftsman*)
- **Event / Context**: Software Craftsmanship North America (SCNA 2012), Chicago, IL (October 2012)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/sandro-mancuso-software-craftsmanship-north-america-2012.yml`
- **Relevance to The Sound Above**: Directly links to the core musical thesis. When engineers rely solely on familiar syntax and tools, they create an illusion of mastery. Mastery requires deliberately stepping into unfamiliar territory where one's standard habits fail.

```
Quote 1.3: Rejecting Academic Abstraction for Tactile Reality
```
> "I was going to these master's programs at night and seeing the academics talking about the stuff that I was supposed to need to know to be successful in my career. And they introduced object-oriented technology in a very academic way that had nothing to do with the objects we were dealing with. And I finally said, you know what, I am going to stop listening to the academics and just pour my time into understanding this technology, which they do not seem to understand... They were talking about 'correct programs,' and I am thinking a correct program is one that people use and is helpful. It is not a mathematical formula here, guys... You could not get this from college."

- **Speaker**: Ken Auer (Founder, RoleModel Software; Pioneer of Software Apprenticeship and Smalltalk Pattern Languages)
- **Event / Context**: UGtastic General Interview Series (2011)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/interview-with-ken-auer-general.yml`
- **Relevance to The Sound Above**: Articulates the separation between credentialed theory and working software. Real engineering formation occurs through direct, iterative feedback with running code and human users, not clean-room mathematical proofs.

```
Quote 1.4: Resisting Stale Entrenchment and Marketplace Conformity
```
> "We should be thinking about how we can proliferate good ideas and let them win in the marketplace of this precious time that we all have, and discourage stale ideas from becoming rotely preached over and over again. I have been to a Java user group in the past where they are talking, and I am not selling, but bless his heart, the guy giving the talk was just sharing ideas and technologies that were very old and outmoded in my opinion. That group would have been much better served at a user group that was happening the same night on the other side of town... How do we discourage the groups that become stale or the talks that become stale, and encourage the ones that are fresh? Because it is always easier for entrenched interests, like the long-running groups, to keep going. It is much harder to start something new."

- **Speaker**: Justin Searls (Co-Founder, Test Double)
- **Event / Context**: Software Craftsmanship North America (SCNA 2012), Chicago, IL (October 2012)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/justin-searls-software-craftsmanship-north-america-2012.yml`
- **Relevance to The Sound Above**: Warns against intellectual entropy. Without continuous curiosity and cross-pollination, technical communities decay into repetitive ritual.

---

## Theme 2: The Craft of Maintenance and Feedback Loops

### Testing, Refactoring, Legacy Stabilization, and Understanding the Machine Beneath

The Software Craftsmanship movement treated automated testing not as an audit obligation or bureaucratic gate, but as a cognitive instrument: an externalized mental model that provides tight, deterministic feedback while exploring complex domains.

```
Quote 2.1: The Lossy Compression of Knowledge and the Need for Deep Study
```
> "There is just so much more that I wish I could put in there. There is so much that is behind those. It is a very lossy compression when you take whatever is in your life, you start making these little axioms, and now it is a four by six card. So chapter two from *Clean Code* actually is condensed to I think like a four or five point card somewhere in the back of the deck now... Nothing could go far enough and nothing could go deep enough to really get to the important stuff. So since then, I have been boning up more on Brain Science: David Rock, Carol Dweck, Csikszentmihalyi, and Jonathan Haidt...
>
> When they are practicing writing code, half of their brain is split and is critiquing and observing how they go about solving their code problems and how they are thinking through the problems. So they are actually kind of like two people, which is hard to do. But by mindfully practicing your code art, you can suddenly realize better ways that you can step things out and things you didn't realize that you need to learn. It is kind of like the ultimate small community: two pair programmers."

- **Speaker**: Tim Ottinger (Co-Author of *Clean Code*; Agile Coach, Object Mentor and Industrial Logic)
- **Event / Context**: UGtastic General Interview Series (2011)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/tim-ottinger-general.yml`
- **Relevance to The Sound Above**: Highlights how surface checklists ("clean code rules") represent lossy compression. Real craftsmanship is reflective metacognition: cultivating an observant inner critic that watches the mind work, identifying cognitive blind spots while navigating problem spaces.

```
Quote 2.2: Fast Feedback and the Symmetry of Simplicity and Testability
```
> "NetBSD differentiates itself by defaulting to every build being a cross-build. This means that the toolchain that builds the system first bootstraps a toolchain from whatever your host system is to whatever the target system you want to build for... NetBSD has a unique culture of testing that is not typically possible in a kernel. They have special technology in the kernel called 'AnyKernel,' which allows any component of the kernel to be targeted either for direct linking into a monolithic kernel or compiling it into a thin layer on top of userland...
>
> This approach to testing benefits NetBSD users by providing fast feedback and the ability to identify and fix issues more quickly. It allows for automated testing of kernel code, which can help catch bugs before they become critical. This recognition that simplicity and orthogonality go hand in hand with testability is fundamental."

- **Speaker**: Amitai Schlair (NetBSD Developer; Agile/Craftsmanship Educator)
- **Event / Context**: Software Craftsmanship North America (SCNA 2013), Chicago, IL (November 2013)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/amitai-schlair-software-craftsmanship-north-america-2013.yml`
- **Relevance to The Sound Above**: Shows that testability is not an afterthought added to an architecture; it is an architectural driver that forces modularity, orthogonality, and clean boundary separation down to operating system kernels.

```
Quote 2.3: Simple Metaphors Over Visual Noise
```
> "Ron bought a tablet PC, I don't know, eight or ten years ago, and we started doing talks with just him drawing. Little graphs and stuff like that: if you do good it will go up, and if you do bad it will go down... We are, as you see with the pictures, left with the fact that I cannot draw very well. Which is why the pictures are all so simple, really...
>
> But it is enough. I would really probably draw them simply even if I were able to draw something that looked real. Because the idea is to catch attention, illuminate the idea, not have people stare at it the way they would stare at great art and not listen to us, because the point is perhaps to listen to the words as well as to see the pictures... We have been giving presentations about this kind of subject for 15 years, and we have developed a style which works for us, and oddly enough, this is sort of how we work anyway."

- **Speaker**: Chet Hendrickson & Ron Jeffries (Signatories of the Agile Manifesto; Extreme Programming Pioneers)
- **Event / Context**: Software Craftsmanship North America (SCNA 2013), Chicago, IL (November 2013)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/chet-hendrickson-ron-jefferies-software-craftsmanship-north-america-2013.yml`
- **Relevance to The Sound Above**: Strips away technical pretension. True communication in software relies on uncluttered, essential mental models rather than elaborate presentation theater.

---

## Theme 3: Apprenticeship, Mentorship, and Community Third Spaces

### How Working Practitioners Learned from Peers Before Social Media Influencer Culture

Before corporate tech branding and algorithmic social feeds dominated technical discourse, knowledge was transmitted through grassroots third spaces: user group meetings in suburban basements, company cafeterias opened to the public, Open Space unconferences, and structured studio apprenticeships.

```
Quote 3.1: Heterophily: Why Homogeneous Networks Stagnate
```
> "One of the concepts I am really interested in is the concept of heterophily. Everybody knows about homophily, the birds-of-a-feather flock-together phenomenon, which is what we saw this morning with all the Ruby people at one table, the Java people at another table. That is nice. But heterophily says: what happens if people who are not similar flock together?
>
> If you live in a homophilous network where everybody you know is a Ruby programmer, the number of new ideas you run into is going to be fairly low because you all read the same things, you all do the same things, you have relatively similar tools. However, if there is one person in your little community who is also an Erlang programmer, then they bring ideas from the Erlang community to the Ruby community, and from the Ruby community to the Erlang community...
>
> This idea that you have a homophilous network that has heterophilous networks woven through it creates something much more valuable. You can say: I am running a Ruby conference, but I am going to bring in somebody who is a UX designer to share some of their insights. Or I am going to bring in somebody who is a concert pianist and bring them in to share some of their insights. And it is different. It is stuff you would not have come up with because you do not belong in that community, that world. And they bring in their new ideas and it changes you, changes your community in ways you would not have organically changed."

- **Speaker**: Adewale Oshineye (Co-Author of *Apprenticeship Patterns: Guidance for the Aspiring Software Craftsman*)
- **Event / Context**: Software Craftsmanship North America (SCNA 2013), Chicago, IL (November 2013)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/adewale-oshineye-software-craftsmanship-north-america-2013.yml`
- **Relevance to The Sound Above**: Serves as a direct academic and practical validation for bringing music theory, concert pianists, Krautrock, and ancient philosophy into software engineering. Homogeneous groups produce predictable, derivative code; breakthrough insights happen at boundary intersections.

```
Quote 3.2: Open Studios, Martial Arts Discipline, and Cross-Pollination
```
> "It comes from a long way back. Starting my career, how I learned everything was really by working with other people and meeting new people. That is how new ideas came into my repertoire, and new languages came into my repertoire. Working with the public, just anyone you can get your hands on, working with them, that is how you grow as a craftsman. One of my concerns at 8th Light was that we were a really tight-knit group, but if we don't have external influences, we are going to stagnate with the knowledge that we have. So it was important to open up 8th Light and invite people in so that we get more cross-pollination...
>
> We call it *waza*. It is a Japanese term something that we used to use a lot in martial arts. It basically means to practice. Waza is our practice term. What the real value of martial arts was, was not self-defense; it was the discipline, the philosophy. That was the real value that I got...
>
> The whole idea behind 8th Light University was that we expected our craftsmen to go to conferences and give talks. Some did, some didn't. And it occurred to us that giving a talk at a conference can be intimidating. We have an audience of people that we share knowledge with, so why not have our craftsmen teach or give talks to the rest of the company? And we're like, well, we are not working on client stuff on Friday afternoons; there are no secrets here. Why don't we just open it up to the public and anyone can come? ... It is informal. There is no polish. A rough cut can just open the door."

- **Speaker**: Micah Martin (Co-Founder, 8th Light; Software Apprenticeship Pioneer)
- **Event / Context**: Software Craftsmanship North America (SCNA 2013), Chicago, IL (November 2013)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/micah-martin-software-craftsmanship-north-america-2013.yml`
- **Relevance to The Sound Above**: Documents how formal apprenticeship firms drew directly on martial arts traditions (*waza*) to build deliberate practice routines, and dismantled corporate IP secrecy to establish open learning studios.

```
Quote 3.3: The Evolution of SCMC: Sustaining Community Without Budget
```
> "Originally Mike and I started the group. Mike did most of the initial setup, and it was originally, the topic was cloud development, cloud computing. We did that for what, about a year and a half? And then we ran out of topics, and we were like, yeah, let's do something different. 2010 is when we had our first SCMC meeting, and then we brought Jim in from 8th Light, Jim Suchy. And that was the first time we actually had a corporate sponsor, when Follett Software Company sponsored our location in McHenry, and that helped out a lot...
>
> Even though we didn't have a corporate sponsor for the earlier cloud developers group, we met at a Panera, we met at a local bar (Duke's Alehouse), the first meeting was at a library, but you know, that was okay. We had to power through that. It wasn't always easy, it was sometimes quite painful, but it goes into something about building community: it doesn't really matter where you meet. When you are trying to build a community, it is not necessarily that you are at a Follett or at a Groupon or at an 8th Light. It is that you are just somewhere where people get together and talk shop, talk about whatever is on their mind with a community, and can speak a similar language and feel some empathy toward each other because we share common interests and industry."

- **Speaker**: Ryan Gerry (Co-Founder, Software Craftsmanship McHenry County [SCMC])
- **Event / Context**: GOTO Chicago 2014, Chicago, IL (May 2014)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/ryan-gerry-goto-conference-2014.yml`
- **Relevance to The Sound Above**: Ground-truth historical record of SCMC (Software Craftsmanship McHenry County) founding in 2009-2010 by Mike Hall, Ryan Gerry, and Jim Suchy. Demonstrates that enduring technical communities do not require venture funding or corporate polish; they require practitioner consistency and physical gathering spaces.

```
Quote 3.4: Radical Hospitality and Institutional Durability
```
> "What has worked well for us? One of the first things that we did when I first became an organizer was make sure we have consistency. Because we want people to know that they can put on their calendar a ChicagoRuby meeting a year in advance. They won't necessarily know the topic, we won't know the topic, but we will know the date, the time, and the place. So with that consistency, everybody can plan around that. And then once you have that, you want to get good speakers...
>
> We actually started off in Franklin Park. We were five guys meeting in a library in Franklin Park when I became organizer. And when I became organizer, I said, 'I am not going to do it by myself. I want other people to work with me.' One of the other guys in that room was Matt Polito...
>
> Lee DeForest said to us, 'Hey, you can meet in the basement of my building in Elmhurst. It is a great spot, like a clubhouse.' But no 'No Girls Allowed' sign. We are very friendly to women and Black people. Very friendly across the board. Usually most groups are pretty welcoming because if people are willing to get together to spend their time talking about tech, there is always one more person to talk to."

- **Speaker**: Ray Hightower (Founding Organizer, ChicagoRuby; President, WisdomGroup)
- **Event / Context**: Software Craftsmanship North America (SCNA 2011), Chicago, IL (November 19, 2011)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/ray-hightower-chicagoruby-software-craftsmanship-north-america-2011.yml`
- **Relevance to The Sound Above**: Chronicles how radical hospitality, welcoming diversity, and relentless logistical consistency turned a five-person gathering in a suburban library into a multi-decade civic institution.

```
Quote 3.5: Peer Apprenticeship as a Sounding Board for Unbaked Ideas
```
> "The spirit of GeekFest started off as just some people learning some stuff together. But over the years, the most consistent theme or spirit has been a place to go, a fairly safe place to go and practice presentations or use this group as a sounding board for ideas or open source projects...
>
> Adrian came and I loved Adrian's talk because it wasn't fully baked. He was saying, 'This is something I am working on. I am interested in people's reactions to this.' And that is the perfect use of GeekFest as a place to get your ideas out there and engage community interests... People weren't afraid to give their opinion, to be a critical thinker, and ask people to think through things and ask tough questions...
>
> We had our apprentices organize it, and I think they provided a lot of enthusiasm about the whole thing. It gives the apprentices an investment in the community."

- **Speaker**: Dave Hoover (Author of *Apprenticeship Patterns*; Co-Founder, Obtiva; Engineering Leader, Groupon)
- **Event / Context**: GeekFest Chicago / Groupon, Chicago, IL (2012)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/dave-hoover-geekfest-geekfest.yml`
- **Relevance to The Sound Above**: Reveals the secret of the apprenticeship model: putting apprentices in charge of community logistics, and exposing working developers to incomplete, unbaked ideas so they can critique and shape them together before production.

---

## Theme 4: Warnings That Aged Well

### Early Predictions of Velocity Traps, Automated Facades, and Institutional Amnesia

A decade before large language models generated syntax without comprehension, the practitioners of the Software Craftsmanship era warned about the exact traps now destabilizing engineering teams: prioritizing shipping velocity over design integrity, confusing mechanical speed with cognitive understanding, and treating foundational code as disposable syntax.

```
Quote 4.1: The Fallacy of Fast Generation Without Verification
```
> "Typing is not the bottleneck."

- **Speaker**: Core aphorism across Obtiva, 8th Light, and the Chicago craftsmanship community (documented in Mike Hall's physical artifacts from 2009 and reiterated across SCNA panels)
- **Context**: Embedded as a cultural touchstone throughout the UGtastic interviews and referenced in *The Sound Above: Episode Minus Zero*
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/assets/subtitles/the-sound-above-episode-00.vtt`
- **Relevance to The Sound Above**: In 2009, this sticker stood on laptops to remind developers that thinking, modeling, and verifying edge cases consumed 95% of engineering time, while typing code consumed 5%. In 2026, when probabilistic models can spit out thousands of lines of syntax in seconds, the truth is amplified: automated code generation accelerates the 5% typing phase while massively increasing the cognitive load of the 95% verification phase.

```
Quote 4.2: The Cyclical Re-Discovery of Forgotten Fundamentals
```
> "I would love to see a small group that was just an 'interesting papers from the history of computer science' group that got together every quarter or something. Like Jim Weirich at the Ruby User Brigade in Columbus, last year or two years ago, he gave a talk of like 10 of the greatest computer science papers in 60 minutes...
>
> What happens bit more organically is an idea is stale, we successfully stop talking about it for a few years, and then somebody brings it up again because it is new to them because they haven't seen it. And so if it is a good idea, it will keep coming back up."

- **Speaker**: Justin Searls (Co-Founder, Test Double)
- **Event / Context**: Software Craftsmanship North America (SCNA 2012), Chicago, IL (October 2012)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/justin-searls-software-craftsmanship-north-america-2012.yml`
- **Relevance to The Sound Above**: Anticipated the amnesia of modern web development. Because software engineering discards its own history every five to seven years, teams continuously reinvent primitive patterns under new branding. Studying "the sound above" connects modern practitioners to foundational computer science discoveries.

```
Quote 4.3: Psychological Safety and Structural Attrition
```
> "The community has changed a lot over the past 10 years... Talking to people that face those kinds of issues, reaching out to people that you know have stopped attending certain conferences and finding out why is a really great reason... It is about communicating and learning. The more you learn, the more you know...
>
> If you have a friend who is a person of color or a woman or somebody with physical or mental disabilities and you ask them about these issues, you kind of care more right away because it is somebody that you care about and you don't want to see treated that way... The statistic on women leaving the industry within 10 years is 60% that leave careers in tech because of the harassment, because of the way that they are treated specifically because of their gender. And that is a really hard thing to deal with... When you see something happening that is not okay, say something. Stand up and say something."

- **Speaker**: Ashe Dryden (Diversity Advocate; Independent Consultant)
- **Event / Context**: UGtastic General Interview Series (2012)
- **Source File**: `file:///Users/mike/github.com/just3ws/just3ws.github.io/_data/transcripts/ashe-dryden-general.yml`
- **Relevance to The Sound Above**: Highlights that technical excellence cannot be decoupled from ethical community stewardship. When exclusive, hostile cultures drive senior, diverse practitioners out of the industry after a decade, institutional knowledge evaporates, accelerating the generational dark age.

---

## Archival Concordance Table

| Interviewee | Primary Affiliation | Event / Year | Repository File | Primary Theme |
| :--- | :--- | :--- | :--- | :--- |
| **Sergio Pereira** | Chicago Alt.NET | SCNA 2011 | `sergio-pereira-chicago-alt-net-software-craftsmanship-north-america-2011.yml` | Professional Agency & Anti-Dogma |
| **Sandro Mancuso** | London Software Craftsmanship | SCNA 2012 | `sandro-mancuso-software-craftsmanship-north-america-2012.yml` | Anti-Dogma & Deliberate Practice |
| **Ken Auer** | RoleModel Software | UGtastic 2011 | `interview-with-ken-auer-general.yml` | Apprenticeship & Tactile Reality |
| **Justin Searls** | Test Double | SCNA 2012 | `justin-searls-software-craftsmanship-north-america-2012.yml` | Historical Literacy & Anti-Stagnation |
| **Tim Ottinger** | Object Mentor / Clean Code | UGtastic 2011 | `tim-ottinger-general.yml` | Metacognition & Pair Feedback |
| **Amitai Schlair** | NetBSD Foundation | SCNA 2013 | `amitai-schlair-software-craftsmanship-north-america-2013.yml` | Testability & Orthogonal Architecture |
| **Chet Hendrickson & Ron Jeffries** | Extreme Programming (XP) | SCNA 2013 | `chet-hendrickson-ron-jefferies-software-craftsmanship-north-america-2013.yml` | Essential Simplicity & Honest Metaphor |
| **Adewale Oshineye** | Google / Apprenticeship Patterns | SCNA 2013 | `adewale-oshineye-software-craftsmanship-north-america-2013.yml` | Heterophily & Cross-Domain Weaving |
| **Micah Martin** | 8th Light | SCNA 2013 | `micah-martin-software-craftsmanship-north-america-2013.yml` | Studio Apprenticeship & Martial Arts Practice |
| **Ryan Gerry** | SCMC Co-Founder | GOTO Chicago 2014 | `ryan-gerry-goto-conference-2014.yml` | Grassroots Gathering & Low-Budget Resilience |
| **Ray Hightower** | ChicagoRuby / WisdomGroup | SCNA 2011 | `ray-hightower-chicagoruby-software-craftsmanship-north-america-2011.yml` | Radical Hospitality & Organizing Durability |
| **Dave Hoover** | Obtiva / Apprenticeship Patterns | GeekFest 2012 | `dave-hoover-geekfest-geekfest.yml` | Unbaked Ideas & Apprentice Empowerment |
| **Ashe Dryden** | Independent Advocate | UGtastic 2012 | `ashe-dryden-general.yml` | Community Ethics & Institutional Retention |
