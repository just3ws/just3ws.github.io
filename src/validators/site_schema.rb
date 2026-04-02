# frozen_string_literal: true

require 'dry-validation'

module Validators
  class BaseContract < Dry::Validation::Contract
    config.messages.backend = :yaml
  end

  class PlatformContract < BaseContract
    params do
      required(:platform).filled(:string)
      required(:url).filled(:string)
      optional(:embed_url).maybe(:string)
    end
  end

  class InterviewContract < BaseContract
    params do
      required(:id).filled(:string)
      required(:title).filled(:string)
      required(:interviewer).filled(:string)
      required(:recorded_date).filled(:date)
      required(:video_asset_id).filled(:string)
      optional(:interviewees).array(:string)
      optional(:topic).maybe(:string)
      optional(:conference).maybe(:string)
      optional(:conference_year).maybe(:integer)
      optional(:community).maybe(:string)
    end
  end

  class VideoAssetContract < BaseContract
    params do
      required(:id).filled(:string)
      required(:title).filled(:string)
      required(:primary_platform).filled(:string)
      required(:published_date).filled(:date)
      required(:platforms).array(:hash)
      optional(:interview_id).maybe(:string)
      optional(:description).maybe(:string)
      optional(:topic).maybe(:string)
      optional(:tags).array(:string)
    end

    rule(:platforms).each do
      if value.is_a?(Hash)
        contract = PlatformContract.new
        result = contract.call(value)
        result.errors.to_h.each do |field, messages|
          key([:platforms, index, field]).failure(messages.join(', '))
        end
      end
    end
  end

  class ConferenceContract < BaseContract
    params do
      required(:name).filled(:string)
      required(:slug).filled(:string)
      optional(:conference).maybe(:string)
      optional(:year).maybe(:integer)
      optional(:location).maybe(:string)
      optional(:start_date).maybe(:date)
      optional(:end_date).maybe(:date)
      optional(:summary).maybe(:string)
      optional(:highlights).array(:string)
    end
  end

  class CommunityContract < BaseContract
    params do
      required(:name).filled(:string)
      required(:slug).filled(:string)
      optional(:summary).maybe(:string)
      optional(:highlights).array(:string)
    end
  end
end
