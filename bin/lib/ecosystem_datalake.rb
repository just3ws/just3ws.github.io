# frozen_string_literal: true

# ---
# name: ecosystem_datalake.rb
# domain: lake
# purpose: Core shared library for the ecosystem datalake across SQLite3, DuckDB, and JSONL
# usage: require_relative 'lib/ecosystem_datalake'
# ---

require 'json'
require 'yaml'
require 'sqlite3'
require 'open3'
require 'fileutils'
require 'time'

class EcosystemDatalake
  ROOT = File.expand_path('../..', __dir__)
  LAKE_DIR = File.join(ROOT, 'lake', 'ecosystem')
  DB_PATH = File.join(LAKE_DIR, 'ecosystem.db')
  JSONL_PATH = File.join(LAKE_DIR, 'ecosystem.jsonl')
  DUCKDB_PATH = File.join(LAKE_DIR, 'ecosystem.duckdb')
  MANIFEST_PATH = File.join(LAKE_DIR, 'ecosystem_manifest.json')

  ORGANIZATIONS = %w[just3ws ugtastic wwworkremote phalanxduel].freeze

  LOCAL_REPOSITORIES = {
    'just3ws/just3ws.github.io' => ROOT,
    'just3ws/ccs' => '/Users/mike/github.com/just3ws/ccs',
    'just3ws/dehum' => '/Users/mike/github.com/just3ws/dehum',
    'just3ws/hallway' => '/Users/mike/github.com/just3ws/hallway',
    'just3ws/bastion' => '/Users/mike/github.com/just3ws/bastion',
    'just3ws/uglst-geosrv' => '/Users/mike/github.com/just3ws/uglst-geosrv',
    'just3ws/nerd-font-cheatsheets' => '/Users/mike/github.com/just3ws/nerd-font-cheatsheets',
    'just3ws/just3ws' => '/Users/mike/github.com/just3ws/just3ws',
    'wwworkremote/wwworkremote' => '/Users/mike/github.com/wwworkremote/wwworkremote',
    'phalanxduel/game' => '/Users/mike/github.com/phalanxduel/game',
    'phalanxduel/game-swiftui' => '/Users/mike/github.com/phalanxduel/game-swiftui',
    'phalanxduel/site' => '/Users/mike/github.com/phalanxduel/site',
    'phalanxduel/wiki' => '/Users/mike/github.com/phalanxduel/wiki',
    'phalanxduel/monitor' => '/Users/mike/github.com/phalanxduel/monitor',
    'just3ws/zdots' => '/Users/mike/.config/zsh',
    'just3ws/vdots' => '/Users/mike/.config/nvim',
    'just3ws/my' => '/Users/mike/my'
  }.freeze

  HISTORICAL_ARTIFACTS = [
    {
      'id' => 'ccc-printable-schedule-photo',
      'initiative' => 'Chicago Code Camp',
      'title' => 'Printable Conference Schedule Matrix Photo Artifact',
      'era' => '2010 - 2012',
      'artifact_type' => 'photo',
      'source_repo' => 'just3ws/just3ws.github.io',
      'file_path' => 'assets/images/portfolio/chicago-code-camp-print-schedule.jpg',
      'description' => 'Original printout of the 9-track conference schedule matrix across 5 session blocks produced by Mike Hall custom scheduling tool.',
      'canonical_url' => 'https://pbs.twimg.com/media/ChTAjcZWkAAHftd.jpg',
      'provenance_details' => {
        'tweet_media' => 'https://pbs.twimg.com/media/ChTAjcZWkAAHftd.jpg',
        'hashtag_archive' => 'https://www.sotwe.com/hashtag/ChicagoCodeCamp',
        'resolution' => '1200x920'
      }
    },
    {
      'id' => 'ccc-printable-schedule-haml',
      'initiative' => 'Chicago Code Camp',
      'title' => 'Printable Schedule View Generator Code',
      'era' => '2010 - 2012',
      'artifact_type' => 'code',
      'source_repo' => 'just3ws/ccs',
      'file_path' => 'app/views/schedules/printable.html.haml',
      'description' => 'Original Haml view rendering the printable table matrix with rooms and time slots.',
      'canonical_url' => 'https://github.com/just3ws/ccs',
      'provenance_details' => {
        'framework' => 'Ruby on Rails',
        'controller' => 'schedules_controller.rb',
        'action' => 'printable'
      }
    },
    {
      'id' => 'ugtastic-footer-provenance',
      'initiative' => 'UGtastic',
      'title' => 'UGtastic Official Brand Social Footer Template',
      'era' => '2011 - 2015',
      'artifact_type' => 'code',
      'source_repo' => 'lake/witc/corpus.db',
      'file_path' => 'consolidated/whoistechcmty/_unsorted/pending/ugtastic/app/views/layouts/_footer.html.haml',
      'description' => 'Original footer template explicitly establishing @ugtastic, github.com/ugtastic, and soundcloud.com/ugtastic.',
      'canonical_url' => 'https://twitter.com/ugtastic',
      'provenance_details' => {
        'corpus_record' => 'consolidated/whoistechcmty/_unsorted/pending/ugtastic/app/views/layouts/_footer.html.haml'
      }
    },
    {
      'id' => 'patreon-founding-vision',
      'initiative' => 'WHOIS Tech Community',
      'title' => 'Patreon Founding Vision and Tools for Everything Manifesto',
      'era' => '2011 - Present',
      'artifact_type' => 'document',
      'source_repo' => 'just3ws/just3ws.github.io',
      'file_path' => '_data/patreon_campaign.yml',
      'description' => 'Canonical founding statement written by Mike Hall for the WHOIS Tech Community Patreon campaign.',
      'canonical_url' => 'https://www.patreon.com/whoistechcmty',
      'provenance_details' => {
        'tagline' => 'Tools for everything',
        'channel' => '@whoistechcmty'
      }
    },
    {
      'id' => 'twatio-audience-overlap-experiment',
      'initiative' => 'twatio.com / UGtastic',
      'title' => 'Twatio Twitter Audience Overlap Experiment & Redirect',
      'era' => '2009 - 2014',
      'artifact_type' => 'web_service',
      'source_repo' => 'just3ws/just3ws.github.io',
      'file_path' => '_data/domain_migration.yml',
      'description' => 'ASP.NET MVC site engineered by Mike Hall to prove that retweeting popular accounts (like Scott Hanselman) reached unique audience against Sergio Pereira counterargument; later redirected to ugtastic.com.',
      'canonical_url' => 'https://web.archive.org/web/20090201000000*/http://twatio.com/',
      'provenance_details' => {
        'stack' => 'ASP.NET MVC',
        'debate_partner' => 'Sergio Pereira',
        'target_redirect' => 'ugtastic.com'
      }
    },
    {
      'id' => 'codeplex-sharpresume-library',
      'initiative' => '#Resume (SharpResume)',
      'title' => 'Just3Ws.SharpResume C# HR-XML 2.5 Implementation (CodePlex & Google Code)',
      'era' => '2006 - 2009',
      'artifact_type' => 'code',
      'source_repo' => 'codeplex/sharpresume',
      'file_path' => '_data/portfolio.yml',
      'description' => 'C# implementation of the HR-XML Consortium 2.5 standardized Resume and CV structure (Just3Ws.SharpResume, SharpResume.Builder, SharpResume.Test), licensed under MIT (Copyright 2006-2009 Just3Ws, Inc.).',
      'canonical_url' => 'https://codeplexarchive.org/project/sharpresume',
      'provenance_details' => {
        'codeplex_url' => 'https://codeplexarchive.org/project/sharpresume',
        'wayback_2007' => 'https://web.archive.org/web/20070510045718/http://www.codeplex.com:80/sharpresume',
        'google_code_svn' => 'https://storage.googleapis.com/google-code-archive-source/v2/code.google.com/sharpresume/source-archive.zip',
        'handles' => 'frogsbrain, just3ws, zalewhol',
        'copyright' => 'Copyright (c) 2006-2009 Just3Ws, Inc.'
      }
    },
    {
      'id' => 'codeplex-nstun-library',
      'initiative' => 'NStun (FrogsBrain.NStun) / TicketsNow',
      'title' => 'FrogsBrain.NStun Native .NET 2.0 C# RFC 3489 STUN Protocol Library',
      'era' => '2006 - 2009',
      'artifact_type' => 'code',
      'source_repo' => 'codeplex/nstun',
      'file_path' => '_posts/2006-11-06-nstun.html',
      'description' => 'Native C# (.NET Framework 2.0.50727 / Visual Studio 2005) implementation of the RFC 3489 STUN UDP NAT traversal protocol, directly correlated with solving real-time distributed ticket broker connectivity at TicketsNow (Nov 2005 to Mar 2007). Published on CodePlex and FrogsBrain.net under the MIT License.',
      'canonical_url' => 'https://codeplexarchive.org/project/nstun',
      'provenance_details' => {
        'codeplex_url' => 'https://codeplexarchive.org/project/nstun',
        'frogsbrain_url' => 'https://web.archive.org/web/20081010042552/http://www.frogsbrain.net:80/content/nstun/default.aspx',
        'runtime' => '.NET Framework 2.0 (v2.0.50727, Visual Studio 2005)',
        'career_correlation' => 'TicketsNow real-time distributed broker NAT traversal (2005-2007)',
        'copyright' => 'Copyright (c) 2007 FrogsBrain.net / 2009 Just3Ws, Inc.'
      }
    },
    {
      'id' => 'rubygems-published-packages',
      'initiative' => 'RubyGems (@just3ws)',
      'title' => 'Published RubyGems Packages: express_pigeon, biscuit-monitor, biscotti (60,304 Downloads)',
      'era' => '2012 - 2019',
      'artifact_type' => 'package',
      'source_repo' => 'just3ws/express_pigeon',
      'file_path' => '_data/portfolio.yml',
      'description' => 'Three production RubyGems authored and published under handle just3ws totaling 60,304 downloads: express_pigeon (v2.4.1, 30,267 downloads, MIT), biscuit-monitor (v0.0.4, 18,026 downloads, CLEAR Spot 4G+ hotspot telemetry), and biscotti (v0.1.4, 12,011 downloads, word-permutation engine).',
      'canonical_url' => 'https://rubygems.org/profiles/just3ws',
      'provenance_details' => {
        'express_pigeon' => 'https://rubygems.org/gems/express_pigeon (30,267 downloads)',
        'biscuit_monitor' => 'https://rubygems.org/gems/biscuit-monitor (18,026 downloads)',
        'biscotti' => 'https://rubygems.org/gems/biscotti (12,011 downloads)',
        'total_downloads' => 60304
      }
    },
    {
      'id' => 'chocolatey-kickstarter-cta-panel',
      'initiative' => 'Chocolatey (ferventcoder/chocolatey.org-archive)',
      'title' => 'Chocolatey.org Top-of-Site Kickstarter Launch CTA Panel (Commit fa6a43b0)',
      'era' => '2010 - 2014',
      'artifact_type' => 'code',
      'source_repo' => 'ferventcoder/chocolatey.org-archive',
      'file_path' => 'chocolatey/Website/Views/Shared/Layout.cshtml',
      'description' => 'Top-of-site Kickstarter widget and call-to-action banner (commit fa6a43b0268178417d4f2420a66964b72ee3bd09, GH-124, featuring the humorous <!-- END KICKSTARTER ANNOY-O-TRON --> comment) built by Mike Hall for friend Rob Reynolds (ferventcoder) on November 14, 2014 to help propel the Chocolatey Kickstarter past its $51,071 funding goal.',
      'canonical_url' => 'https://github.com/ferventcoder/chocolatey.org-archive/commit/fa6a43b0268178417d4f2420a66964b72ee3bd09',
      'provenance_details' => {
        'commit_sha' => 'fa6a43b0268178417d4f2420a66964b72ee3bd09',
        'merge_sha' => 'f5685ed976c026ab9392732944732820ebdc9108',
        'issue' => 'GH-124',
        'collaborator' => 'Rob Reynolds (@ferventcoder)',
        'prior_history' => '2010 Iron Languages Podcast ("That nu Thing" on NuGet) & 2012 UGtastic Interview (https://www.youtube.com/watch?v=fLgdVVPCWZ8)'
      }
    },
    {
      'id' => 'clojars-semantic-csv-release',
      'initiative' => 'Clojure & Clojars (metasoarous/semantic-csv & plik)',
      'title' => 'Clojure Multi-Delimiter CSV Ingestion & metasoarous/semantic-csv Clojars Release Catalyst',
      'era' => '2017',
      'artifact_type' => 'code',
      'source_repo' => 'just3ws/clojure-exercises-001',
      'file_path' => 'plik/project.clj',
      'description' => 'While building plik (a Clojure Compojure/Ring service consuming pipe, comma, and space-delimited files with clojure-csv and semantic-csv), Mike Hall discovered :transform-header was unreleased on Clojars, packaged [self/semantic-csv "0.1.0-just3ws"] in a local Maven repository (commit 6fb2d789), and filed metasoarous/semantic-csv#49 on January 25, 2017, catalyzing the official 0.2.0 Clojars release.',
      'canonical_url' => 'https://github.com/metasoarous/semantic-csv/issues/49',
      'provenance_details' => {
        'upstream_issue' => 'https://github.com/metasoarous/semantic-csv/issues/49',
        'custom_artifact' => '[self/semantic-csv "0.1.0-just3ws"]',
        'local_commit' => 'https://github.com/just3ws/clojure-exercises-001/commit/6fb2d78971a9cf66d745a11a0841523f631fc6b7',
        'maintainer' => 'Christopher Small (@metasoarous)'
      }
    },
    {
      'id' => 'coderwall-open-source-and-badges',
      'initiative' => 'Coderwall & Assembly Made',
      'title' => 'Coderwall Open-Source Steward (#1 Contributor, 634 Commits) & coderwall-badges Archive',
      'era' => '2014 - 2015',
      'artifact_type' => 'code',
      'source_repo' => 'coderwall/coderwall-legacy',
      'file_path' => '_data/resume/positions/assembly.yml',
      'description' => 'As #1 all-time contributor to coderwall/coderwall-legacy (634 commits, 856 GitHub stars), Mike Hall led the open-source security audit, zero-downtime MongoDB-to-PostgreSQL migration (PR #227), badge achievement logic fixes (octopussy.rb), and created assemblymade/coderwall-badges (commits b5ff7796, 0fc8fb01) preserving 60+ original DrawIt vector badge artworks.',
      'canonical_url' => 'https://github.com/coderwall/coderwall-legacy',
      'provenance_details' => {
        'coderwall_repo' => 'https://github.com/coderwall/coderwall-legacy (856 stars, 301 forks, 634 commits by just3ws)',
        'badges_repo' => 'https://github.com/assemblymade/coderwall-badges',
        'rails_enum_pr' => 'https://github.com/rails/rails/pull/17990'
      }
    },
    {
      'id' => 'github-arctic-code-vault-2020',
      'initiative' => 'GitHub Archive Program / Arctic Code Vault (Svalbard, Norway)',
      'title' => '2020 GitHub Arctic Code Vault Contributor (02/02/2020 Snapshot)',
      'era' => '2014 - 2020',
      'artifact_type' => 'archive_record',
      'source_repo' => 'coderwall/coderwall-legacy',
      'file_path' => '_data/portfolio.yml',
      'description' => 'Preserved on piqlFilm silver-halide polyester reels 250 meters deep in the Svalbard permafrost in the 2020-02-02 GitHub Arctic Code Vault snapshot. Officially cited repositories on github.com/just3ws include countries/countries (commit ec5d33ea, 2014-06-18), coderwall/coderwall-legacy (634 commits by just3ws, #1 contributor), asm-helpful/helpful-web (commits eda66bf9, 528cf37f, c7b7a269, 503275cf, a99642b1 in May-June 2014), alongside just3ws/nerd-font-cheatsheets, just3ws/biscotti, just3ws/zdots, just3ws/vdots, and just3ws/just3ws.github.io.',
      'canonical_url' => 'https://github.com/users/just3ws/achievements/arctic-code-vault-contributor/detail',
      'provenance_details' => {
        'unlocked_at' => '2020-02-02T08:00:00Z',
        'countries_commit' => 'https://github.com/countries/countries/commit/ec5d33ea',
        'coderwall_legacy' => 'https://github.com/coderwall/coderwall-legacy (634 commits)',
        'helpful_web' => 'https://github.com/asm-helpful/helpful-web (7+ commits in May-June 2014)',
        'nerd_font_cheatsheets' => 'https://github.com/just3ws/nerd-font-cheatsheets (Starstruck x2, 129 stars)'
      }
    }
  ].freeze

  COMMUNITY_MILESTONES = [
    {
      'id' => 'milestone-2006-codeplex-frogsbrain',
      'event_date' => '2006-10-29',
      'year' => 2006,
      'era' => 'Pre-GitHub Open Source & .NET Foundations (2006-2008)',
      'initiative' => "Frog's Brain / CodePlex / TicketsNow",
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'CodePlex Membership (frogsbrain) & NStun .NET 2.0 RFC 3489 STUN Library',
      'description' => 'While engineering real-time distributed broker connectivity at TicketsNow on .NET Framework 2.0 (v2.0.50727, Visual Studio 2005), Mike Hall joins Microsoft CodePlex under handle frogsbrain (October 29, 2006) and publishes NStun (FrogsBrain.NStun), a native C# implementation of the RFC 3489 STUN UDP NAT traversal protocol.',
      'details_json' => {
        'handle' => 'frogsbrain',
        'runtime' => '.NET Framework 2.0.50727 (Visual Studio 2005)',
        'career_correlation' => 'TicketsNow real-time distributed broker NAT traversal',
        'profile_wayback' => 'https://web.archive.org/web/20081009115645/http://www.codeplex.com:80/site/users/view/frogsbrain',
        'nstun_archive' => 'https://codeplexarchive.org/project/nstun',
        'blog_post' => '_posts/2006-11-06-nstun.html'
      }.to_json
    },
    {
      'id' => 'milestone-2007-schemainsight-sharpresume',
      'event_date' => '2007-05-10',
      'year' => 2007,
      'era' => 'Pre-GitHub Open Source & .NET Foundations (2006-2008)',
      'initiative' => '#Resume (SharpResume) & SchemaInSight',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => '#Resume (SharpResume) HR-XML 2.5 C# API & SchemaInSight on CodePlex',
      'description' => 'Mike Hall coordinates #Resume (Just3Ws.SharpResume, C# implementation of the HR-XML Consortium 2.5 Resume specification) and SchemaInSight (.NET 2.0 SQL Server schema inspection API) on CodePlex, Google Code, and FrogsBrain.net.',
      'details_json' => {
        'sharpresume_codeplex' => 'https://codeplexarchive.org/project/sharpresume',
        'sharpresume_wayback_2007' => 'https://web.archive.org/web/20070510045718/http://www.codeplex.com:80/sharpresume',
        'frogsbrain_net_2008' => 'https://web.archive.org/web/20081009033456/http://www.frogsbrain.net:80/',
        'copyright' => 'Copyright (c) 2006-2009 Just3Ws, Inc.'
      }.to_json
    },
    {
      'id' => 'milestone-2008-chicago-altnet',
      'event_date' => '2008-11-12',
      'year' => 2008,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'Chicago Alt.NET',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'First User Group Presentation at Chicago Alt.NET (NHaml View Engine)',
      'description' => 'Mike Hall delivers his first user group presentation at Chicago Alt.NET on NHaml alongside Adam Tybor on Spark at Redpoint Technologies in the Sears Tower.',
      'details_json' => {
        'speaker' => 'Mike Hall',
        'topic' => 'NHaml Alternative View Engine for ASP.NET MVC',
        'co_presenter' => 'Adam Tybor on Spark',
        'venue' => 'Redpoint Technologies, 84th Floor Sears Tower',
        'citation_meeting_archive' => 'https://web.archive.org/web/20081101091417/http://www.chicagoalt.net/Home',
        'citation_slides' => 'https://www.slideshare.net/chicagoaltnet'
      }.to_json
    },
    {
      'id' => 'milestone-2009-scmc-founding',
      'event_date' => '2009-01-15',
      'year' => 2009,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'Software Craftsmanship McHenry County',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'Founding of Software Craftsmanship McHenry County (SCMC)',
      'description' => 'Mike Hall founds SCMC to bring deliberate practice, coding katas, and craftsmanship principles to the northwest Chicago suburbs.',
      'details_json' => { 'founder' => 'Mike Hall', 'handle' => '@scmchenry', 'focus' => 'Coding Katas & Peer Review' }.to_json
    },
    {
      'id' => 'milestone-2009-twatio-experiment',
      'event_date' => '2009-02-01',
      'year' => 2009,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'twatio.com',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'Twatio Twitter Audience Overlap Experiment (twatio.com)',
      'description' => 'Mike Hall builds twatio.com on ASP.NET MVC following a technical debate with Sergio Pereira to prove empirically that retweets from high-follower accounts reach unique audiences; later redirected to ugtastic.com.',
      'details_json' => {
        'stack' => 'ASP.NET MVC',
        'debate_partner' => 'Sergio Pereira',
        'hypothesis' => 'Retweeting popular accounts reaches unique audience segments',
        'citation_wayback' => 'https://web.archive.org/web/20090201000000*/http://twatio.com/'
      }.to_json
    },
    {
      'id' => 'milestone-2010-chicago-code-camp',
      'event_date' => '2010-05-15',
      'year' => 2010,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'Chicago Code Camp',
      'repo_full_name' => 'just3ws/ccs',
      'event_type' => 'community_milestone',
      'title' => 'Chicago Code Camp Volunteer & Conference Website Developer',
      'description' => 'Chicago Code Camp was an existing conference; Mike Hall volunteered and assisted for a couple years and built the conference website (just3ws/ccs) for at least three years of conferences.',
      'details_json' => {
        'role' => 'Volunteer & Website Developer',
        'conference' => 'Chicago Code Camp (Existing community conference)',
        'tenure' => 'Volunteered for a couple years, built website for at least 3 conferences',
        'engine' => 'Rails ccs platform, speaker management, and printable schedule generator'
      }.to_json
    },
    {
      'id' => 'milestone-2011-ugtastic-interviews',
      'event_date' => '2011-06-01',
      'year' => 2011,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'UGtastic',
      'repo_full_name' => 'ugtastic/.github',
      'event_type' => 'community_milestone',
      'title' => 'Launch of UGtastic Video Oral History Archive',
      'description' => 'Mike Hall begins conducting on-camera interviews with technology community leaders, speakers, and organizers using Flip video cameras.',
      'details_json' => { 'equipment' => 'Flip Video Cameras', 'total_interviews' => 218, 'channel' => '@ugtastic' }.to_json
    },
    {
      'id' => 'milestone-2012-ugtastic-first-capture',
      'event_date' => '2012-04-14',
      'year' => 2012,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'UGtastic',
      'repo_full_name' => 'ugtastic/.github',
      'event_type' => 'community_milestone',
      'title' => 'First Internet Archive Capture of ugtastic.com',
      'description' => 'First recorded Wayback Machine capture of ugtastic.com documenting the community video interview platform.',
      'details_json' => {
        'domain' => 'ugtastic.com',
        'first_capture' => 'https://web.archive.org/web/20120414040704/http://www.ugtastic.com/',
        'latest_capture' => 'https://web.archive.org/web/20250831080513/http://www.ugtastic.com/'
      }.to_json
    },
    {
      'id' => 'milestone-2012-rubygems-biscuit-monitor',
      'event_date' => '2012-07-31',
      'year' => 2012,
      'era' => 'Distributed Services & Micro-Apps (2012-2015)',
      'initiative' => 'RubyGems (@just3ws)',
      'repo_full_name' => 'just3ws/biscuit-monitor',
      'event_type' => 'community_milestone',
      'title' => 'Published biscuit-monitor RubyGem (18,026 Downloads) & express_pigeon (30,267 Downloads)',
      'description' => 'Mike Hall publishes biscuit-monitor (monitoring CLEAR Spot 4G+ personal hotspots for field interviews) and maintains express_pigeon (transactional email and list automation Ruby SDK, 30,267 downloads) on RubyGems.org.',
      'details_json' => {
        'rubygems_profile' => 'https://rubygems.org/profiles/just3ws',
        'biscuit_monitor' => 'https://rubygems.org/gems/biscuit-monitor',
        'express_pigeon' => 'https://rubygems.org/gems/express_pigeon',
        'biscotti' => 'https://rubygems.org/gems/biscotti'
      }.to_json
    },
    {
      'id' => 'milestone-2014-coderwall-open-source',
      'event_date' => '2014-09-12',
      'year' => 2014,
      'era' => 'Distributed Services & Micro-Apps (2012-2015)',
      'initiative' => 'Coderwall / Assembly Made',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'Coderwall Open-Source Transition (#1 Contributor, 634 Commits) & coderwall-badges',
      'description' => 'At Assembly Made, Mike Hall leads the open-sourcing of Coderwall (coderwall/coderwall-legacy, 856 stars, 634 commits by just3ws), creates assemblymade/coderwall-badges preserving 60+ original DrawIt vector badges, executes the zero-downtime MongoDB-to-PostgreSQL migration, and contributes upstream to Ruby on Rails (PR #17990).',
      'details_json' => {
        'coderwall_legacy' => 'https://github.com/coderwall/coderwall-legacy',
        'coderwall_badges' => 'https://github.com/assemblymade/coderwall-badges',
        'rails_pr' => 'https://github.com/rails/rails/pull/17990'
      }.to_json
    },
    {
      'id' => 'milestone-2014-chocolatey-kickstarter-cta',
      'event_date' => '2014-11-14',
      'year' => 2014,
      'era' => 'Distributed Services & Micro-Apps (2012-2015)',
      'initiative' => 'Chocolatey (Rob Reynolds / ferventcoder)',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'Chocolatey.org Top-of-Site Kickstarter Launch CTA Panel (Commit fa6a43b0)',
      'description' => 'Continuing a friendship with Rob Reynolds (@ferventcoder) spanning the 2010 Iron Languages Podcast on NuGet and 2012 UGtastic interview on Chocolatey, Mike Hall authors the top-of-site Kickstarter CTA header banner on chocolatey.org (commit fa6a43b0, GH-124) during the final week of the campaign.',
      'details_json' => {
        'commit_url' => 'https://github.com/ferventcoder/chocolatey.org-archive/commit/fa6a43b0268178417d4f2420a66964b72ee3bd09',
        'interview_2012' => 'https://www.youtube.com/watch?v=fLgdVVPCWZ8',
        'podcast_2010' => '_posts/2010-08-09-upcoming-iron-languages-podcast-episodes.html'
      }.to_json
    },
    {
      'id' => 'milestone-2017-clojars-semantic-csv',
      'event_date' => '2017-01-25',
      'year' => 2017,
      'era' => 'Autonomous Microservices & Kubernetes (2015-2020)',
      'initiative' => 'Clojure & Clojars (semantic-csv / plik)',
      'repo_full_name' => 'just3ws/clojure-exercises-001',
      'event_type' => 'community_milestone',
      'title' => 'Clojure CSV Ingestion (plik) & metasoarous/semantic-csv#49 Clojars Release',
      'description' => 'While building the plik Clojure multi-delimiter CSV service, Mike Hall vendors custom artifact [self/semantic-csv "0.1.0-just3ws"] for :transform-header support and opens metasoarous/semantic-csv#49, catalyzing the official 0.2.0 release to Clojars.',
      'details_json' => {
        'issue_url' => 'https://github.com/metasoarous/semantic-csv/issues/49',
        'commit_url' => 'https://github.com/just3ws/clojure-exercises-001/commit/6fb2d78971a9cf66d745a11a0841523f631fc6b7',
        'clojars_package' => 'https://clojars.org/semantic-csv'
      }.to_json
    },
    {
      'id' => 'milestone-2017-whois-transition',
      'event_date' => '2017-11-17',
      'year' => 2017,
      'era' => 'Autonomous Microservices & Kubernetes (2015-2020)',
      'initiative' => 'WHOIS Tech Community',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'First Capture of UGtastic Transition to WHOIS Tech Community',
      'description' => 'First Internet Archive capture documenting the rename and rebrand transition from UGtastic to WHOIS Tech Community on ugtastic.com.',
      'details_json' => {
        'domain' => 'ugtastic.com',
        'transition_capture' => 'https://web.archive.org/web/20171117114045/https://www.ugtastic.com/',
        'brand_transition' => 'UGtastic to WHOIS Tech Community'
      }.to_json
    },
    {
      'id' => 'milestone-2014-uglst-launch',
      'event_date' => '2014-01-11',
      'year' => 2014,
      'era' => 'Distributed Services & Micro-Apps (2012-2015)',
      'initiative' => 'UGl.st',
      'repo_full_name' => 'just3ws/uglst-geosrv',
      'event_type' => 'community_milestone',
      'title' => 'UGl.st User-Group List Launch & Heart Glyph Interface',
      'description' => 'Mike Hall launches UGl.st (User-Group List) to map developer meetups and communities, featuring the heart glyph in the registration interface; initial capture 2014-01-11 and final snapshot under Mike ownership on 2014-12-22.',
      'details_json' => {
        'domain' => 'ugl.st',
        'first_capture' => 'https://web.archive.org/web/20140111160057/https://ugl.st/',
        'last_ownership_snapshot' => 'https://web.archive.org/web/20141222063128/https://ugl.st/',
        'ui_signature' => 'heart glyph registration interface',
        'creator' => 'Mike Hall'
      }.to_json
    },
    {
      'id' => 'milestone-2014-patreon-whoistechcmty',
      'event_date' => '2014-04-01',
      'year' => 2014,
      'era' => 'Distributed Services & Micro-Apps (2012-2015)',
      'initiative' => 'WHOIS Tech Community',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => 'Launch of WHOIS Tech Community Patreon ("Tools for everything")',
      'description' => 'Patreon launch to fund independent equipment, production improvements, and deep profiles of community volunteers without sponsor bias.',
      'details_json' => { 'platform' => 'Patreon', 'tagline' => 'Tools for everything' }.to_json
    },
    {
      'id' => 'milestone-2020-arctic-code-vault',
      'event_date' => '2020-02-02',
      'year' => 2020,
      'era' => 'Autonomous Microservices & Kubernetes (2015-2020)',
      'initiative' => 'GitHub Arctic Code Vault (Svalbard, Norway)',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'community_milestone',
      'title' => '2020 GitHub Arctic Code Vault Snapshot (countries, coderwall-legacy, helpful-web & just3ws Repos)',
      'description' => 'On February 2, 2020 (08:00 UTC), Mike Hall contributions across countries/countries (commit ec5d33ea), coderwall/coderwall-legacy (634 commits), asm-helpful/helpful-web (commits eda66bf9, 528cf37f, c7b7a269, 503275cf, a99642b1), just3ws/nerd-font-cheatsheets, just3ws/biscotti, just3ws/zdots, just3ws/vdots, and just3ws/just3ws.github.io are archived in the GitHub Arctic Code Vault in Svalbard, Norway.',
      'details_json' => {
        'snapshot_date' => '2020-02-02T08:00:00Z',
        'achievement_url' => 'https://github.com/just3ws?achievement=arctic-code-vault-contributor&tab=achievements',
        'cited_repos' => ['countries/countries', 'coderwall/coderwall-legacy', 'asm-helpful/helpful-web', 'just3ws/nerd-font-cheatsheets', 'just3ws/biscotti']
      }.to_json
    }
  ].freeze

  TURNING_POINT_COMMITS = [
    {
      'id' => 'commit-2011-ccs-printable-schedule',
      'event_date' => '2011-05-13',
      'year' => 2011,
      'era' => 'Craftsmanship Genesis (2008-2012)',
      'initiative' => 'Chicago Code Camp',
      'repo_full_name' => 'just3ws/ccs',
      'event_type' => 'turning_point',
      'title' => 'Commit 9a7d7035: Added Print-Friendly Schedule Matrix in Haml',
      'description' => 'Authored the custom schedule matrix generator in app/views/schedules/printable.html.haml producing the 9-track conference printout.',
      'details_json' => { 'sha' => '9a7d7035', 'author' => 'Michael D. Hall', 'file' => 'app/views/schedules/printable.html.haml' }.to_json
    },
    {
      'id' => 'commit-2016-canonical-repo-genesis',
      'event_date' => '2016-12-05',
      'year' => 2016,
      'era' => 'GitHub Pages Genesis & Control Plane (2016-2017)',
      'initiative' => 'just3ws.github.io',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'turning_point',
      'title' => 'Commit adcc35b0: Genesis of Canonical Web Presence and Engineering Resume',
      'description' => 'Initial commit establishing Mike Hall canonical engineering website, semantic HTML resume, and structured microdata.',
      'details_json' => { 'sha' => 'adcc35b0', 'author' => 'Mike Hall' }.to_json
    },
    {
      'id' => 'commit-2017-zdots-founding',
      'event_date' => '2017-05-26',
      'year' => 2017,
      'era' => 'GitHub Pages Genesis & Control Plane (2016-2017)',
      'initiative' => 'zdots',
      'repo_full_name' => 'just3ws/zdots',
      'event_type' => 'turning_point',
      'title' => 'Founding of zdots Observable Personal Control Plane',
      'description' => 'Established the root platform for service lifecycles, automated backups, and local intelligence tooling.',
      'details_json' => { 'path' => '~/.config/zsh', 'purpose' => 'Personal control plane' }.to_json
    },
    {
      'id' => 'commit-2017-vdots-founding',
      'event_date' => '2017-06-02',
      'year' => 2017,
      'era' => 'GitHub Pages Genesis & Control Plane (2016-2017)',
      'initiative' => 'vdots',
      'repo_full_name' => 'just3ws/vdots',
      'event_type' => 'turning_point',
      'title' => 'Founding of vdots Native-First Neovim Configuration',
      'description' => 'Established native-first Lua editing platform with built-in LSP and semicolon-leader ergonomics.',
      'details_json' => { 'path' => '~/.config/nvim', 'editor' => 'Neovim' }.to_json
    },
    {
      'id' => 'commit-2021-wwworkremote-founding',
      'event_date' => '2021-09-25',
      'year' => 2021,
      'era' => 'Calm Systems & Local Platforms (2018-2022)',
      'initiative' => 'wwworkremote',
      'repo_full_name' => 'wwworkremote/wwworkremote',
      'event_type' => 'turning_point',
      'title' => 'Genesis of WwworkRemote Local-First Career Control Plane',
      'description' => 'Engineered calm, local-first search, triage, and application pipeline with zero algorithmic noise.',
      'details_json' => { 'org' => 'wwworkremote', 'type' => 'local-first system' }.to_json
    },
    {
      'id' => 'commit-2022-phalanxduel-founding',
      'event_date' => '2022-07-10',
      'year' => 2022,
      'era' => 'Calm Systems & Local Platforms (2018-2022)',
      'initiative' => 'phalanxduel',
      'repo_full_name' => 'phalanxduel/phalanxduel',
      'event_type' => 'turning_point',
      'title' => 'Genesis of Phalanx Duel Deterministic Engine',
      'description' => 'Engineered a tactical 1v1 card game with server-authoritative TypeScript engine, replay verification, and Go CLI.',
      'details_json' => { 'engine' => 'TypeScript', 'cli' => 'duel-cli in Go' }.to_json
    },
    {
      'id' => 'commit-2023-fluffle-whisper',
      'event_date' => '2023-04-06',
      'year' => 2023,
      'era' => 'Oral History & AI Audio Renaissance (2023-2026)',
      'initiative' => 'fluffle',
      'repo_full_name' => 'just3ws/fluffle',
      'event_type' => 'turning_point',
      'title' => 'Genesis of fluffle Local Whisper Transcription Pipeline',
      'description' => 'Built local AI transcription tooling to preserve long-form oral history recordings.',
      'details_json' => { 'model' => 'Whisper', 'focus' => 'oral history speech-to-text' }.to_json
    },
    {
      'id' => 'commit-2026-resume-oral-history-expansion',
      'event_date' => '2026-02-01',
      'year' => 2026,
      'era' => 'Autonomous Intake & Forensic Audio (2026)',
      'initiative' => 'just3ws.github.io',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'turning_point',
      'title' => 'Commit 10499a2c: Oral History Renaissance & Full Archive Ingestion',
      'description' => 'Promoted minimal resume to index and initiated complete ingestion of 211+ UGtastic and SCMC interviews.',
      'details_json' => { 'sha' => '10499a2c', 'scope' => '211+ interviews, JSON-LD, Vimeo/YouTube' }.to_json
    },
    {
      'id' => 'commit-2026-dehum-forensic-engine',
      'event_date' => '2026-10-12',
      'year' => 2026,
      'era' => 'Autonomous Intake & Forensic Audio (2026)',
      'initiative' => 'dehum',
      'repo_full_name' => 'just3ws/dehum',
      'event_type' => 'turning_point',
      'title' => 'Creation of dehum High-Voltage EMI Audio Forensic Engine',
      'description' => 'Engineered specialized DSP filters for 345,000-volt transmission line EMI hum, corona decrackle, and clock drift.',
      'details_json' => { 'voltage' => '345kV', 'dsp' => 'SoX multi-stage notch and decrackle' }.to_json
    },
    {
      'id' => 'commit-2026-autonomous-media-pipeline',
      'event_date' => '2026-10-15',
      'year' => 2026,
      'era' => 'Autonomous Intake & Forensic Audio (2026)',
      'initiative' => 'just3ws.github.io',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'turning_point',
      'title' => 'Commit ad3348ae: Autonomous Media Intake, Maildir Queues & Live SSE Streamer',
      'description' => 'Engineered Google Drive automated video intake, BPMN state tracking, chunked YouTube uploads, and real-time dashboard.',
      'details_json' => { 'sha' => 'ad3348ae', 'queues' => 'incoming, pending, processing, blocked, processed, failed' }.to_json
    },
    {
      'id' => 'commit-2026-legacy-routes-smart-404',
      'event_date' => '2026-10-17',
      'year' => 2026,
      'era' => 'Autonomous Intake & Forensic Audio (2026)',
      'initiative' => 'just3ws.github.io',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'turning_point',
      'title' => 'Commit 723b5969: Smart Legacy Route Remapping & In-Browser 404 Recovery',
      'description' => 'Compiled route index across 2,540 asset keys and built automatic redirection and suggestion cards for historical traffic.',
      'details_json' => { 'sha' => '723b5969', 'domains' => 'ugtastic.com, whoistechcmty.com, chicagocodecamp.com' }.to_json
    },
    {
      'id' => 'commit-2026-ecosystem-datalake-architecture',
      'event_date' => '2026-10-18',
      'year' => 2026,
      'era' => 'Autonomous Intake & Forensic Audio (2026)',
      'initiative' => 'just3ws.github.io',
      'repo_full_name' => 'just3ws/just3ws.github.io',
      'event_type' => 'turning_point',
      'title' => 'Commit 05ecb376: Unified Ecosystem Datalake in SQLite3 & DuckDB',
      'description' => 'Architected cross-organization datalake synthesizing 66+ repos, 2,790+ commits, historical artifacts, and timeline events.',
      'details_json' => { 'sha' => '05ecb376', 'formats' => 'SQLite3 FTS5, DuckDB, JSONL' }.to_json
    }
  ].freeze

  def self.era_for_year(year)
    case year.to_i
    when 2008..2012 then 'Craftsmanship Genesis (2008-2012)'
    when 2013..2015 then 'Distributed Services & Micro-Apps (2012-2015)'
    when 2016..2017 then 'GitHub Pages Genesis & Control Plane (2016-2017)'
    when 2018..2022 then 'Calm Systems & Local Platforms (2018-2022)'
    when 2023..2025 then 'Oral History & AI Audio Renaissance (2023-2025)'
    else 'Autonomous Intake & Forensic Audio (2026)'
    end
  end

  def initialize(db_path = DB_PATH)
    @db_path = db_path
    FileUtils.mkdir_p(LAKE_DIR)
  end

  def db
    @db ||= SQLite3::Database.new(@db_path).tap do |d|
      d.results_as_hash = true
    end
  end

  def setup_schema!
    db.execute('PRAGMA journal_mode = WAL;')
    db.execute('PRAGMA synchronous = NORMAL;')

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS organizations (
        id INTEGER PRIMARY KEY,
        login TEXT UNIQUE NOT NULL,
        name TEXT,
        description TEXT,
        url TEXT,
        public_repos INTEGER DEFAULT 0,
        created_at TEXT,
        avatar_url TEXT
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS repositories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        organization TEXT NOT NULL,
        name TEXT NOT NULL,
        full_name TEXT UNIQUE NOT NULL,
        description TEXT,
        url TEXT,
        primary_language TEXT,
        is_private INTEGER DEFAULT 0,
        is_archived INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT,
        pushed_at TEXT,
        local_path TEXT,
        commit_count INTEGER DEFAULT 0
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS commits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        repo_name TEXT NOT NULL,
        sha TEXT NOT NULL,
        author_name TEXT,
        author_email TEXT,
        committed_at TEXT NOT NULL,
        message TEXT,
        files_changed INTEGER DEFAULT 0,
        additions INTEGER DEFAULT 0,
        deletions INTEGER DEFAULT 0,
        UNIQUE(repo_name, sha)
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS historical_artifacts (
        id TEXT PRIMARY KEY,
        initiative TEXT NOT NULL,
        title TEXT NOT NULL,
        era TEXT NOT NULL,
        artifact_type TEXT NOT NULL,
        source_repo TEXT,
        file_path TEXT,
        description TEXT,
        canonical_url TEXT,
        provenance_details TEXT
      );
    SQL

    db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS timeline_events (
        id TEXT PRIMARY KEY,
        event_date TEXT NOT NULL,
        year INTEGER NOT NULL,
        era TEXT NOT NULL,
        initiative TEXT NOT NULL,
        repo_full_name TEXT,
        event_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        details_json TEXT
      );
    SQL

    db.execute <<-SQL
      CREATE VIRTUAL TABLE IF NOT EXISTS ecosystem_fts USING fts5(
        entity_type UNINDEXED,
        entity_id UNINDEXED,
        title,
        content,
        repo_or_initiative
      );
    SQL
  end

  def build!(commit_limit: 500, verbose: false)
    setup_schema!
    puts 'Harvesting organizations and repositories via gh api...' if verbose

    # 1. Organizations & Repositories
    ORGANIZATIONS.each do |org|
      org_data = fetch_org_metadata(org)
      if org_data
        db.execute(<<-SQL, [org_data['id'], org_data['login'], org_data['name'], org_data['description'], org_data['html_url'], org_data['public_repos'], org_data['created_at'], org_data['avatar_url']])
          INSERT OR REPLACE INTO organizations (id, login, name, description, url, public_repos, created_at, avatar_url)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?);
        SQL
      end

      repos = fetch_org_repos(org)
      puts "  -> Found #{repos.size} repos for #{org}" if verbose
      repos.each do |r|
        full_name = "#{org}/#{r['name']}"
        local_path = LOCAL_REPOSITORIES[full_name]
        primary_lang = r['primaryLanguage'] ? r['primaryLanguage']['name'] : nil

        db.execute(<<-SQL, [org, r['name'], full_name, r['description'], r['url'], primary_lang, r['isPrivate'] ? 1 : 0, r['isArchived'] ? 1 : 0, r['createdAt'], r['updatedAt'], r['pushedAt'], local_path])
          INSERT OR REPLACE INTO repositories (organization, name, full_name, description, url, primary_language, is_private, is_archived, created_at, updated_at, pushed_at, local_path)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        SQL
      end
    end

    # 2. Releases across key repos
    fetch_and_store_releases(verbose: verbose)

    # 3. Local Commits
    puts 'Harvesting git commit history from local working repositories...' if verbose
    LOCAL_REPOSITORIES.each do |repo_full_name, local_path|
      next unless Dir.exist?(local_path)
      commits = harvest_commits(repo_full_name, local_path, commit_limit)
      puts "  -> #{repo_full_name}: #{commits.size} commits harvested" if verbose

      db.transaction do
        commits.each do |c|
          db.execute(<<-SQL, [c['repo_name'], c['sha'], c['author_name'], c['author_email'], c['committed_at'], c['message']])
            INSERT OR IGNORE INTO commits (repo_name, sha, author_name, author_email, committed_at, message)
            VALUES (?, ?, ?, ?, ?, ?);
          SQL
        end

        db.execute('UPDATE repositories SET commit_count = ? WHERE full_name = ?;', [commits.size, repo_full_name])
      end
    end

    # 4. Historical Artifacts
    puts 'Indexing historical artifacts...' if verbose
    HISTORICAL_ARTIFACTS.each do |art|
      db.execute(<<-SQL, [art['id'], art['initiative'], art['title'], art['era'], art['artifact_type'], art['source_repo'], art['file_path'], art['description'], art['canonical_url'], art['provenance_details'].to_json])
        INSERT OR REPLACE INTO historical_artifacts (id, initiative, title, era, artifact_type, source_repo, file_path, description, canonical_url, provenance_details)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
      SQL
    end

    # 5. Timeline Events Compilation
    compile_timeline_events!(verbose: verbose)

    # 6. FTS Index
    populate_fts_index!(verbose: verbose)

    # 7. Exports (JSONL and DuckDB)
    export_jsonl!
    export_duckdb!

    # 8. Manifest
    manifest = generate_manifest
    File.write(MANIFEST_PATH, JSON.pretty_generate(manifest))
    manifest
  end

  def compile_timeline_events!(verbose: false)
    puts 'Compiling chronological timeline events across ecosystem...' if verbose

    # A. Community Milestones
    COMMUNITY_MILESTONES.each do |m|
      db.execute(<<-SQL, [m['id'], m['event_date'], m['year'], m['era'], m['initiative'], m['repo_full_name'], m['event_type'], m['title'], m['description'], m['details_json']])
        INSERT OR REPLACE INTO timeline_events (id, event_date, year, era, initiative, repo_full_name, event_type, title, description, details_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
      SQL
    end

    # B. Turning Point Commits
    TURNING_POINT_COMMITS.each do |t|
      db.execute(<<-SQL, [t['id'], t['event_date'], t['year'], t['era'], t['initiative'], t['repo_full_name'], t['event_type'], t['title'], t['description'], t['details_json']])
        INSERT OR REPLACE INTO timeline_events (id, event_date, year, era, initiative, repo_full_name, event_type, title, description, details_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
      SQL
    end

    # C. Repository Creation Events
    db.execute('SELECT full_name, organization, name, description, created_at FROM repositories WHERE created_at IS NOT NULL;').each do |r|
      date_str = r['created_at'].to_s.slice(0, 10)
      next if date_str.nil? || date_str.empty?
      year = date_str.slice(0, 4).to_i
      era = self.class.era_for_year(year)
      id = "repo-created-#{r['full_name'].tr('/', '-')}"
      title = "Repository Created: #{r['full_name']}"
      desc = r['description'] || "Creation of #{r['full_name']} repository."
      details = { 'organization' => r['organization'], 'repo' => r['name'], 'created_at' => r['created_at'] }.to_json

      db.execute(<<-SQL, [id, date_str, year, era, r['organization'], r['full_name'], 'repo_creation', title, desc, details])
        INSERT OR REPLACE INTO timeline_events (id, event_date, year, era, initiative, repo_full_name, event_type, title, description, details_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
      SQL
    end
  end

  def populate_fts_index!(verbose: false)
    puts 'Rebuilding FTS5 search index...' if verbose
    db.execute('DELETE FROM ecosystem_fts;')

    # Index Repositories
    db.execute('SELECT id, full_name, description, primary_language FROM repositories;').each do |r|
      content = [r['description'], r['primary_language']].compact.join(' ')
      db.execute(<<-SQL, ['repository', r['id'].to_s, r['full_name'], content, r['full_name']])
        INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative)
        VALUES (?, ?, ?, ?, ?);
      SQL
    end

    # Index Commits
    db.execute('SELECT id, repo_name, sha, message, author_name FROM commits;').each do |c|
      title = "#{c['repo_name']} @ #{c['sha'][0..7]}: #{c['message']}"
      content = "#{c['message']} Author: #{c['author_name']}"
      db.execute(<<-SQL, ['commit', c['id'].to_s, title, content, c['repo_name']])
        INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative)
        VALUES (?, ?, ?, ?, ?);
      SQL
    end

    # Index Artifacts
    db.execute('SELECT id, initiative, title, description, file_path FROM historical_artifacts;').each do |a|
      content = "#{a['description']} #{a['file_path']}"
      db.execute(<<-SQL, ['artifact', a['id'], a['title'], content, a['initiative']])
        INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative)
        VALUES (?, ?, ?, ?, ?);
      SQL
    end

    # Index Timeline Events
    db.execute('SELECT id, initiative, title, description, repo_full_name FROM timeline_events;').each do |e|
      content = "#{e['description']} #{e['repo_full_name']}"
      db.execute(<<-SQL, ['timeline_event', e['id'], e['title'], content, e['initiative']])
        INSERT INTO ecosystem_fts (entity_type, entity_id, title, content, repo_or_initiative)
        VALUES (?, ?, ?, ?, ?);
      SQL
    end
  end

  def export_jsonl!
    File.open(JSONL_PATH, 'w') do |f|
      db.execute('SELECT * FROM organizations;').each { |row| f.puts({ 'type' => 'organization' }.merge(row).to_json) }
      db.execute('SELECT * FROM repositories;').each { |row| f.puts({ 'type' => 'repository' }.merge(row).to_json) }
      db.execute('SELECT * FROM historical_artifacts;').each { |row| f.puts({ 'type' => 'artifact' }.merge(row).to_json) }
      db.execute('SELECT * FROM timeline_events;').each { |row| f.puts({ 'type' => 'timeline_event' }.merge(row).to_json) }
      db.execute('SELECT * FROM commits;').each { |row| f.puts({ 'type' => 'commit' }.merge(row).to_json) }
    end
  end

  def export_duckdb!
    return unless system('which duckdb >/dev/null 2>&1')

    # Remove old duckdb file if present to rebuild clean
    FileUtils.rm_f(DUCKDB_PATH)
    sql_script = <<-SQL
      CREATE TABLE organizations AS SELECT * FROM read_json_auto('#{JSONL_PATH}') WHERE type = 'organization';
      CREATE TABLE repositories AS SELECT * FROM read_json_auto('#{JSONL_PATH}') WHERE type = 'repository';
      CREATE TABLE historical_artifacts AS SELECT * FROM read_json_auto('#{JSONL_PATH}') WHERE type = 'artifact';
      CREATE TABLE timeline_events AS SELECT * FROM read_json_auto('#{JSONL_PATH}') WHERE type = 'timeline_event';
      CREATE TABLE commits AS SELECT * FROM read_json_auto('#{JSONL_PATH}') WHERE type = 'commit';

      CREATE VIEW v_timeline AS
        SELECT event_date, year, era, initiative, repo_full_name, event_type, title, description
        FROM timeline_events
        ORDER BY event_date ASC;

      CREATE VIEW v_yearly_activity AS
        SELECT strftime('%Y', committed_at::TIMESTAMP) AS year, repo_name, count(*) AS commit_count
        FROM commits
        WHERE committed_at IS NOT NULL
        GROUP BY 1, 2
        ORDER BY 1 ASC, 3 DESC;

      CREATE VIEW v_org_summary AS
        SELECT organization, count(*) AS repo_count, sum(commit_count) AS indexed_commits
        FROM repositories
        GROUP BY 1
        ORDER BY 2 DESC;

      CREATE VIEW v_language_distribution AS
        SELECT coalesce(primary_language, 'Unspecified') AS language, count(*) AS repo_count
        FROM repositories
        GROUP BY 1
        ORDER BY 2 DESC;
    SQL

    escaped_script = sql_script.gsub('"', '\"')
    cmd = "duckdb -dark-mode \"#{DUCKDB_PATH}\" -c \"#{escaped_script}\" < /dev/null"
    system(cmd)
  end

  def generate_manifest
    total_repos = db.get_first_value('SELECT count(*) FROM repositories;')
    total_commits = db.get_first_value('SELECT count(*) FROM commits;')
    total_artifacts = db.get_first_value('SELECT count(*) FROM historical_artifacts;')
    total_events = db.get_first_value('SELECT count(*) FROM timeline_events;')
    earliest_commit = db.get_first_value('SELECT min(committed_at) FROM commits;')
    latest_commit = db.get_first_value('SELECT max(committed_at) FROM commits;')

    {
      'generated_at' => Time.now.utc.iso8601,
      'organizations' => ORGANIZATIONS,
      'metrics' => {
        'repositories_indexed' => total_repos,
        'commits_indexed' => total_commits,
        'historical_artifacts' => total_artifacts,
        'timeline_events' => total_events,
        'earliest_commit_at' => earliest_commit,
        'latest_commit_at' => latest_commit
      },
      'storage' => {
        'sqlite_db' => DB_PATH,
        'jsonl_stream' => JSONL_PATH,
        'duckdb_file' => DUCKDB_PATH,
        'sqlite_size_bytes' => File.size?(DB_PATH) || 0,
        'jsonl_size_bytes' => File.size?(JSONL_PATH) || 0,
        'duckdb_size_bytes' => File.size?(DUCKDB_PATH) || 0
      }
    }
  end

  # Query Capabilities
  def query_fts(search_term, limit: 15)
    query = <<-SQL
      SELECT entity_type, entity_id, title, content, repo_or_initiative,
             bm25(ecosystem_fts) as rank
      FROM ecosystem_fts
      WHERE ecosystem_fts MATCH ?
      ORDER BY rank
      LIMIT ?;
    SQL
    db.execute(query, [search_term, limit])
  end

  def query_timeline(era: nil, limit: 100)
    if era && !era.empty?
      db.execute(<<-SQL, ["%#{era}%", limit])
        SELECT event_date, era, initiative, repo_full_name, event_type, title, description
        FROM timeline_events
        WHERE era LIKE ?
        ORDER BY event_date ASC
        LIMIT ?;
      SQL
    else
      db.execute(<<-SQL, [limit])
        SELECT event_date, era, initiative, repo_full_name, event_type, title, description
        FROM timeline_events
        ORDER BY event_date ASC
        LIMIT ?;
      SQL
    end
  end

  def query_stats
    stats = {}
    stats[:org_count] = db.get_first_value('SELECT count(*) FROM organizations;')
    stats[:repo_count] = db.get_first_value('SELECT count(*) FROM repositories;')
    stats[:commit_count] = db.get_first_value('SELECT count(*) FROM commits;')
    stats[:artifact_count] = db.get_first_value('SELECT count(*) FROM historical_artifacts;')
    stats[:timeline_events] = db.get_first_value('SELECT count(*) FROM timeline_events;')

    stats[:repos_by_org] = db.execute(<<-SQL)
      SELECT organization, count(*) as count, sum(commit_count) as total_commits
      FROM repositories
      GROUP BY organization
      ORDER BY count DESC;
    SQL

    stats[:languages] = db.execute(<<-SQL)
      SELECT coalesce(primary_language, 'Unknown') as lang, count(*) as count
      FROM repositories
      GROUP BY lang
      ORDER BY count DESC;
    SQL

    stats[:timeline_by_era] = db.execute(<<-SQL)
      SELECT era, count(*) as count, min(event_date) as start_date, max(event_date) as end_date
      FROM timeline_events
      GROUP BY era
      ORDER BY min(event_date) ASC;
    SQL

    stats
  end

  def query_sql(sql_str)
    db.execute(sql_str)
  end

  def query_duckdb(query_str)
    return 'DuckDB not installed.' unless system('which duckdb >/dev/null 2>&1')
    target = File.file?(DUCKDB_PATH) ? "\"#{DUCKDB_PATH}\"" : "\"#{JSONL_PATH}\""
    cmd = if File.file?(DUCKDB_PATH)
            "duckdb -dark-mode #{target} -c \"#{query_str.gsub('"', '\"')}\" < /dev/null"
          else
            "duckdb -dark-mode -c \"#{query_str.gsub('"', '\"')}\" < /dev/null"
          end
    out, status = Open3.capture2(cmd)
    status.success? ? out : "Error: #{out}"
  end

  private

  def fetch_org_metadata(org_login)
    out, status = Open3.capture2("gh api orgs/#{org_login} 2>/dev/null")
    if status.success?
      JSON.parse(out) rescue nil
    else
      out2, status2 = Open3.capture2("gh api users/#{org_login} 2>/dev/null")
      JSON.parse(out2) rescue nil if status2.success?
    end
  end

  def fetch_org_repos(org_login)
    cmd = "gh repo list #{org_login} --limit 100 --json name,description,isPrivate,isArchived,createdAt,updatedAt,pushedAt,url,primaryLanguage"
    out, status = Open3.capture2(cmd)
    status.success? ? (JSON.parse(out) rescue []) : []
  end

  def fetch_and_store_releases(verbose: false)
    repos_with_releases = %w[phalanxduel/phalanxduel just3ws/just3ws.github.io]
    repos_with_releases.each do |repo|
      out, status = Open3.capture2("gh api repos/#{repo}/releases 2>/dev/null")
      next unless status.success?
      releases = JSON.parse(out) rescue []
      releases.each do |rel|
        date_str = rel['published_at'].to_s.slice(0, 10)
        next if date_str.nil? || date_str.empty?
        year = date_str.slice(0, 4).to_i
        id = "release-#{repo.tr('/', '-')}-#{rel['tag_name'].tr('/', '-')}"
        title = "Release: #{repo} #{rel['name'] || rel['tag_name']}"
        desc = rel['body'] ? rel['body'].slice(0, 300) : "Release #{rel['tag_name']}"
        details = { 'tag' => rel['tag_name'], 'published_at' => rel['published_at'], 'url' => rel['html_url'] }.to_json

        db.execute(<<-SQL, [id, date_str, year, self.class.era_for_year(year), repo.split('/').first, repo, 'release', title, desc, details])
          INSERT OR REPLACE INTO timeline_events (id, event_date, year, era, initiative, repo_full_name, event_type, title, description, details_json)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        SQL
      end
    end
  end

  def harvest_commits(repo_full_name, local_path, limit)
    return [] unless Dir.exist?(local_path) && (Dir.exist?(File.join(local_path, '.git')) || File.file?(File.join(local_path, '.git')))

    cmd = "git -C \"#{local_path}\" log -n #{limit} --pretty=format:\"%H%x1f%an%x1f%ae%x1f%aI%x1f%s\""
    out, status = Open3.capture2(cmd)
    return [] unless status.success?

    commits = []
    out.each_line do |line|
      line = line.strip
      next if line.empty?
      parts = line.split("\x1f")
      next unless parts.size >= 5

      commits << {
        'repo_name' => repo_full_name,
        'sha' => parts[0],
        'author_name' => parts[1],
        'author_email' => parts[2],
        'committed_at' => parts[3],
        'message' => parts[4]
      }
    end
    commits
  end
end
