---
layout: post
title: "The Fluffle Precursor: Distributed whisper.cpp, Dead Rabbit Radio & Transcribing at Scale"
date: 2026-10-16 14:00:00 -0500
permalink: /ai/2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster/
redirect_from:
  - /2026/10/16/the-fluffle-precursor-distributed-whisper-and-the-dead-rabbit-cluster.html
ai_generated: true
human_led: true
source_kind: ai-augmented-human-led
robots: noindex,follow
sitemap: false
categories: [ai, audio, craftsmanship]
tags: [whisper, raspberry-pi, distributed-systems, dead-rabbit-radio, audio-transcription, imposter-syndrome]
description: "How a 5-node Raspberry Pi cluster transcribing 1,000 episodes of Dead Rabbit Radio in April 2023 unlocked the distributed audio pipelines, whisper.cpp mechanics, and painful lessons that made modern autonomous media publication possible."
---

On the aluminum lid of the MacBook Air where I am writing this, right next to the Apple logo, sits a circular Dead Rabbit Radio sticker.

Most people who see it assume it is just another piece of quirky podcast merchandise. To me, it is a permanent physical artifact of one of the most intense, ambitious, and humbling technical experiments I ever ran. It is the story of how a 5-node Raspberry Pi cluster, over one thousand podcast episodes, early ChatGPT assistance, and a brilliant independent audio creator named Jason Carpenter taught me how to transcribe audio at scale.

It is also the story of how imposter syndrome and cognitive overload caused me to shut down and walk away from a project I loved, and why those painful lessons directly enabled the autonomous local AI media pipeline running on this machine today.

---

### The Pre-Whisper Wall: A Decade of Silent Hard Drives

Between 2011 and 2015, I hauled 35 pounds of camera gear, wireless lavalier microphones, and laptops through conference hallways across North America. From SCNA to RailsConf and GOTO Chicago, I recorded over 200 technical interviews for UGtastic (first captured on the Internet Archive on April 14, 2012, prior to our 2017 transition to WHOIS Tech Community). I sat with language creators, framework maintainers, community organizers, and frontline practitioners.

When the camera stopped rolling, I hit an impassable operational wall: transcription.

In 2013, human transcription services cost between $1.00 and $2.00 per audio minute. For a single 30-minute interview, you paid $45. For a catalog of 200 conversations spanning more than 100 hours of spoken technical discourse, transcription was an impossible four-figure luxury for an unfunded grassroots community project. Early automated speech-to-text cloud APIs from Google and AWS were catastrophically inaccurate on developer terminology. Words like "NHibernate," "StructureMap," "NUnit," or "Cucumber" were turned into phonetic gibberish.

The video files sat dormant on external hard drives for nearly ten years. I knew the knowledge was in those recordings, but without accurate full-text search, semantic indexing, and WebVTT subtitle tracks, they were effectively locked in digital amber.

---

### April 2023: The Spark of whisper.cpp

Everything changed in late 2022 and early 2023. OpenAI published the open-weights Whisper speech recognition model. Shortly thereafter, Georgi Gerganov released `whisper.cpp`, a high-performance C/C++ port of Whisper capable of running on consumer CPUs without Python dependencies or massive GPU server clusters.

For the first time in history, the economics of transcription collapsed to zero marginal cost. You did not need a cloud contract with an API provider. You just needed electricity and CPU cycles.

This was also the dawn of practical LLM coding assistance. In April 2023, modern agentic environments like Claude Code or Antigravity did not exist yet. ChatGPT had just introduced GPT-4. I was exploring whether an engineer working alone could collaborate with an LLM in a browser window to architect a complete distributed media processing system from scratch.

To test whether whisper.cpp could handle large-scale, real-world spoken audio, I needed a massive dataset. I did not want to start with the precious UGtastic archives because those tapes had varying room acoustics, background hallway noise, and multiple speakers talking over each other. I needed a single, clean, consistent audio source with an enormous volume of episodes to stress-test throughput, memory limits, and hardware stability.

That is how I found *Dead Rabbit Radio*.

---

### Why Dead Rabbit Radio?

*Dead Rabbit Radio* (DRR) is a daily podcast hosted, researched, and produced entirely by Jason Carpenter. Jason covers paranormal history, obscure conspiracies, folklore, and bizarre true crime news with infectious enthusiasm, dry humor, and genuine curiosity.

I was already a dedicated listener, but as an engineer looking for a benchmark dataset, DRR was an absolute dream:

1. **A Single Consistent Speaker**: Jason is the sole host. There was zero speaker diarization complexity, no overlapping crosstalk, and no volume fluctuations between multiple microphones.
2. **Predictable Vocal Cadence**: Jason speaks with a distinct rhythmic cadence, pacing his delivery with clear pronunciation that closely mirrors my own natural speaking tempo. If whisper.cpp could transcribe Jason reliably, it could transcribe me.
3. **Massive Daily Output**: By spring 2023, Jason had published over one thousand daily episodes. That represented hundreds of hours of contiguous audio.
4. **Pure Joy and Independence**: Jason records with passion and integrity, completely outside corporate media networks. It made listening to the test runs a joy rather than a chore.

I created a new open-source repository on GitHub: [`github.com/just3ws/fluffle`](https://github.com/just3ws/fluffle), named after "The Fluffle," the affectionate community term for Dead Rabbit Radio listeners.

---

### The 5-Node Raspberry Pi Cluster

I did not have an expensive cloud cluster or a bank of high-end NVIDIA GPUs. What I had in my home lab was a stack of five Raspberry Pi single-board computers.

Running whisper.cpp on a single Raspberry Pi CPU is slow. Transcribing an hour of audio can take two to three hours of computation. If I wanted to transcribe over one thousand episodes without waiting eighteen months, I had to build a distributed pipeline.

Working alongside early ChatGPT to draft Ruby orchestration scripts, I designed a distributed architecture across five network nodes (`node01` through `node05`):

```
                        +----------------------+
                        |   Controller (MBA)   |
                        |   Podcast Feed Pull  |
                        +----------+-----------+
                                   |
         +-------------------------+-------------------------+
         |                         |                         |
         v                         v                         v
+-----------------+       +-----------------+       +-----------------+
| node01 (RPi 4)  |       | node02 (RPi 4)  |       | node03 (RPi 4)  |
| whisper.cpp     |       | whisper.cpp     |       | whisper.cpp     |
| ggml-small.bin  |       | ggml-small.bin  |       | ggml-small.bin  |
+-----------------+       +-----------------+       +-----------------+
         |                         |                         |
         +-------------------------+-------------------------+
                                   |
                                   v
                        +----------------------+
                        |  Git Repository      |
                        |  2,034 Transcripts   |
                        |  .txt + .srt Output  |
                        +----------------------+
```

#### 1. Size-Balancing Bin Packing (`bin/distribution`)
Podcast episodes vary wildly in duration. Some episodes were twenty minutes; others were forty-five minutes. Naively assigning episode counts to nodes caused some Pis to finish in hours while others ran for days.

I wrote a bin-packing distribution tool in Ruby (`bin/distribution`). It scanned the downloaded audio directory, calculated total byte volume, divided the total by the number of nodes, and rotated files across the cluster to ensure equal computational weight across every node:

```ruby
# From just3ws/fluffle: bin/distribution
total_size = files.sum { |file| file[:size] }
size_per_node = total_size / nodes.size

files.each do |file|
  node = nodes.first
  if node_files_size.first + file[:size] <= size_per_node || node == nodes.last
    node_files[node] << file[:path]
    node_files_size[0] += file[:size]
  else
    nodes.rotate!
    node_files_size.rotate!
  end
end
```

#### 2. Network Distribution (`bin/distribute`)
Using `Net::SSH` and `rsync`, the master machine deployed the allocated audio files over the local network to `deploy@nodeXX:~/podcasts/`, tracking completed uploads in `distributed.yaml` and deleting local staging files to conserve disk space.

#### 3. Worker Execution & Thermal Cooldowns (`bin/transcribe`)
Each Raspberry Pi executed a bash worker loop that ran `whisper.cpp` using the `ggml-small.bin` model, generating both plain text (`.txt`) and subtitle (`.srt`) tracks:

```bash
# From just3ws/fluffle: bin/transcribe
time ~/whisper.cpp/main -m ~/whisper.cpp/models/ggml-small.bin \
  -f "$file" -osrt -otxt 2>&1 | tee -ai "${episode}.log"

mv "${file}.srt" "${episode}.srt"
mv "${file}.txt" "${episode}.txt"
rm "${file}"

sleep 120
```

Notice that final line: `sleep 120`.

On a Raspberry Pi 4 running all four ARM cores at 100% load during speech recognition, thermal throttling was brutal. Without an active cooling fan, the SoC temperatures would spike into the mid-80s Celsius. The two-minute sleep between episodes allowed the heatsinks to cool back to baseline before ingesting the next audio file.

---

### 2,034 Transcripts & Reaching Out to Jason

Over the course of several weeks, the cluster hummed quietly in my basement. It chewed through the Dead Rabbit Radio catalog, producing **2,034 distinct transcript files** (1,017 text documents and 1,017 subtitle files).

I was determined to work completely in the open and respect the creator. I drafted a clear copyright and licensing framework: all episode content remained the exclusive copyright of Jason Carpenter, while the derived transcriptions were published under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 license (CC BY-NC-ND 4.0).

I sent an email to Jason at `DeadRabbitRadio@gmail.com`. I explained that I was a fan, that I was testing distributed transcription tools, that I had transcribed his catalog to make it searchable and accessible for deaf and hard-of-hearing listeners, and that I wanted to make sure he was comfortable with the project.

Jason was exceptionally gracious. He replied with kindness, humor, and curiosity, expressing appreciation for the effort and giving his blessing to the fan-driven archive.

I felt on top of the world. The technology worked. The creator was on board. The transcripts were live on GitHub.

Then I hit the cliff.

---

### The Cliff: Imposter Syndrome and Cognitive Overload

Emboldened by the success with Dead Rabbit Radio, my brain did what ambitious engineer brains so often do: I tried to generalize the solution to the entire world at once.

I decided that `fluffle` should not just transcribe Dead Rabbit Radio. It should become a universal podcast transcription and aggregation platform. I began pulling in RSS feeds from other creators.

Immediately, the neat assumptions of the DRR laboratory crumbled:

1. **RSS and ATOM Chaos**: No two podcast feeds behaved the same way. Some used `<enclosure>`, others embedded audio links in CDATA blocks. Some had broken byte-range headers that failed `rsync`.
2. **Audio Format Nightmares**: Variable bitrates, corrupt ID3 tags, stereo panning where one speaker was 12dB quieter than the other, and 22kHz mono files that caused whisper.cpp to hallucinate repetitive loops.
3. **Episode Numbering Inconsistency**: Feeds changed naming formats every six months. Season tags, special episodes, Patreon preview tags, and unpadded numbers broke my sorting and deduplication logic.

At the exact same time, my professional responsibilities at work intensified dramatically. I was leading critical Observability and systems modernization initiatives, navigating high-severity production incidents, distributed tracing rollouts, and immense architectural complexity.

My working memory became completely exhausted. Every evening when I looked at my computer, the mountain of broken podcast edge cases felt insurmountable. I began to tell myself that I was fooling myself, that building a real media pipeline was beyond my abilities, and that I was an imposter playing with toy scripts.

The guilt was suffocating. Jason had been so generous and kind in his email, and I felt I had promised a polished, evergreen resource that I could no longer sustain. Instead of sending a simple, honest email saying, *"Jason, I am overwhelmed with work right now and need to pause this,"* I froze.

I stopped updating the repository. I stopped responding. I ghosted Jason, not out of malice or apathy, but out of sheer, paralyzing embarrassment.

I was so ashamed of having stepped back that I could not even bring myself to listen to *Dead Rabbit Radio* for months afterward. Every time I saw the show in my podcast app, I felt an intense sting of failure.

---

### What The Fluffle Taught Me

For a long time, I carried `just3ws/fluffle` as a private regret. But as software craftsmen, we have to look honestly at our scars and recognize what our failed experiments actually built.

The `fluffle` experiment was not a failure. It was the essential skunkworks laboratory that laid the foundation for everything I have built since.

1. **Deterministic Pre-Processing Over Magic**: `fluffle` proved that trying to feed raw, inconsistent audio files directly into machine learning models will always fail. You must normalize audio deterministically before inference. That lesson directly produced our 16kHz mono PCM extraction filters and channel-splitting algorithms.
2. **Maildir State Machines Over Ad-Hoc Scripts**: In `fluffle`, when a Pi rebooted or dropped an SSH connection, files were stranded in ambiguous states. That pain directly drove the design of our Maildir architecture (`pending`, `processing`, `processed`, `failed`) and the atomic `JobSubstateTracker` we rely on today.
3. **Lexical Priming & Brand Repair**: Transcribing Jason Carpenter taught me how Whisper systematically misinterprets proper nouns. When `fluffle` generated words like "Garbender" or "Karpner" for Carpenter, I wrote `replacements.yaml`. That simple YAML dictionary evolved directly into our custom domain lexicon priming that now restores "UGtastic," "SCMC," and "StructureMap" flawlessly.
4. **Local Hardware Sovereignty**: Watching five $35 Raspberry Pis transcribe one thousand hours of spoken audio without sending a single byte to an external cloud API permanently anchored my commitment to local-first, zero-egress software craftsmanship.

---

### Closing the Loop

Today, the entire pipeline is different. The five Raspberry Pis have been superseded by Apple Silicon M-series hardware running `ztranscribe` with Metal GPU acceleration. What took a Raspberry Pi two hours now runs in ninety seconds. The fragile bash loops have been replaced by robust, verified Ruby engines, real-time telemetry, and formal BPMN state machines.

All 218 UGtastic interviews are fully transcribed, searchable, and preserved in our local CareerOS datalake. The dream I had in 2013 is finally reality.

None of it would exist without *Dead Rabbit Radio* and the `fluffle` experiment.

If Jason Carpenter ever reads this: I want to apologize for going quiet in 2023. You were gracious and encouraging to an engineer who reached out from the void, and my silence was born entirely of burnout and embarrassment, never a lack of respect. Thank you for your daily storytelling, your humor, and your dedication to your craft. You gave me the perfect laboratory to learn how speech recognition works in the real world.

The Dead Rabbit Radio sticker remains proudly on this laptop. The code is still open on GitHub. And the lessons are alive in every line of code this pipeline runs today.
