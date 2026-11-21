# frozen_string_literal: true

require 'spec_helper'
require 'jekyll'
require 'yaml'
require '_plugins/ramblin_aimblin_episode_generator'
require 'src/validators/ramblin_aimblin_rendered_article_contract'

# rubocop:disable-next Metrics/BlockLength
RSpec.describe Jekyll::RamblinAimblinEpisodeGenerator do
  let(:site_data) { { 'ramblin_aimblin_episodes' => [episode] } }
  let(:site) { instance_double(Jekyll::Site, data: site_data, pages: [], source: '/tmp') }
  let(:episode) do
    YAML.safe_load_file(File.expand_path('../fixtures/ramblin_aimblin_episode.yml', __dir__))
  end

  it 'generates an episode page only from a complete released record' do
    page = instance_double(Jekyll::Page)
    allow(Jekyll::RamblinAimblinEpisodePage).to receive(:new).and_return(page)

    described_class.new.generate(site)

    expect(site.pages).to contain_exactly(page)
    expect(Jekyll::RamblinAimblinEpisodePage).to have_received(:new).with(
      site, '/tmp', 'episode-one', episode
    )
  end

  it 'initializes generated episode pages in memory without reading missing source files' do
    expect(Jekyll::RamblinAimblinEpisodePage.ancestors).to include(Jekyll::PageWithoutAFile)
    allow(Jekyll.logger).to receive(:error)
    real_site = Jekyll::Site.new(Jekyll.configuration('source' => '/tmp', 'quiet' => true))

    page = Jekyll::RamblinAimblinEpisodePage.new(real_site, '/tmp', 'episode-one', episode)

    expect(Jekyll.logger).not_to have_received(:error)
    expect(page.data['permalink']).to eq('/series/ramblin-aimblin/episodes/episode-one/')
    expect(page.data['robots']).to eq('noindex,follow')
    expect(page.content).to eq('{% include ramblin_aimblin_episode.html %}')
  end

  it 'rejects held or draft records instead of copying them into the public site' do
    episode['status'] = 'held'

    expect { described_class.new.generate(site) }
      .to raise_error(Jekyll::Errors::FatalException, /public release contract/)
  end

  it 'rejects a short without an explicitly confirmed anchor relationship' do
    episode['shorts'][0]['related_video_confirmed'] = false

    expect { described_class.new.generate(site) }
      .to raise_error(Jekyll::Errors::FatalException, /public release contract/)
  end

  it 'accepts a public release status without exposing private review evidence' do
    page = instance_double(Jekyll::Page)
    allow(Jekyll::RamblinAimblinEpisodePage).to receive(:new).and_return(page)

    expect { described_class.new.generate(site) }.not_to raise_error

    episode['release_checks'] = 'pending'
    expect { described_class.new.generate(site) }
      .to raise_error(Jekyll::Errors::FatalException, /public release contract/)
  end

  it 'rejects records that point to the field-notes playlist' do
    episode['playlist_id'] = 'PLNtb969T2-l0'

    expect { described_class.new.generate(site) }
      .to raise_error(Jekyll::Errors::FatalException, /public release contract/)
  end

  it 'rejects article paths outside the AI archive' do
    episode['article_path'] = '/interviews/private/'

    expect { described_class.new.generate(site) }
      .to raise_error(Jekyll::Errors::FatalException, /public release contract/)
  end

  it 'rejects duplicate episode IDs and routes' do
    site_data['ramblin_aimblin_episodes'] << episode.merge('slug' => 'episode-two')

    expect { described_class.new.generate(site) }
      .to raise_error(Jekyll::Errors::FatalException, /public release contract/)
  end

  it 'requires the built article to link to the anchor, playlist, sources, and shorts and include disclosure' do
    Dir.mktmpdir('ramblin-pair') do |dest|
      article = File.join(dest, 'ai/series/ramblin-aimblin/episode-one/index.html')
      FileUtils.mkdir_p(File.dirname(article))
      content = <<~ARTICLE
        #{episode['anchor_url']}
        https://www.youtube.com/playlist?list=PLBL0frEzrqqQ
        https://www.just3ws.com/series/ramblin-aimblin/episodes/#{episode['slug']}/
        #{episode['source_links'][0]['url']}
        #{episode['shorts'][0]['url']}
        #{episode['ai_disclosure']}
      ARTICLE
      File.write(article, content)
      episode_page = File.join(dest, 'series/ramblin-aimblin/episodes/episode-one/index.html')
      FileUtils.mkdir_p(File.dirname(episode_page))
      File.write(episode_page, <<~EPISODE)
        <meta name="robots" content="noindex,follow">
        <h1>#{episode['title']}</h1>
        #{episode['anchor_url']}
        #{episode['article_url']}
        https://www.youtube.com/playlist?list=PLBL0frEzrqqQ
        #{episode['source_links'][0]['url']}
        #{episode['shorts'][0]['url']}
        #{episode['ai_disclosure']}
      EPISODE
      rendered_site = instance_double(Jekyll::Site, dest: dest, data: site_data)

      expect { RamblinAimblinRenderedArticleContract.validate!(rendered_site) }.not_to raise_error

      File.write(episode_page, '<h1>missing episode content</h1>')
      expect { RamblinAimblinRenderedArticleContract.validate!(rendered_site) }
        .to raise_error(Jekyll::Errors::FatalException, /generated episode page/)

      File.write(episode_page, <<~EPISODE)
        <meta name="robots" content="noindex,follow">
        <h1>#{episode['title']}</h1>
        #{episode['anchor_url']}
        #{episode['article_url']}
        https://www.youtube.com/playlist?list=PLBL0frEzrqqQ
        #{episode['source_links'][0]['url']}
        #{episode['shorts'][0]['url']}
        #{episode['ai_disclosure']}
      EPISODE
      File.write(article, 'links removed')
      expect { RamblinAimblinRenderedArticleContract.validate!(rendered_site) }
        .to raise_error(Jekyll::Errors::FatalException, /required links or disclosure/)
    end
  end
end
