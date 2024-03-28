# frozen_string_literal: true

require_relative "http"

module OpenRouter
  class ServerError < StandardError; end

  class Client
    include OpenRouter::HTTP

    # Initializes the client with optional configurations.
    def initialize
      yield(OpenRouter.configuration) if block_given?
    end

    # Performs a chat completion request to the OpenRouter API.
    # @param messages [Array<Hash>] Array of message hashes with role and content, like [{role: "user", content: "What is the meaning of life?"}]
    # @param model [String|Array] Model identifier, or array of model identifiers if you want to fallback to the next model in case of failure
    # @param providers [Array<String>] Optional array of provider identifiers, ordered by priority
    # @param transforms [Array<String>] Optional array of strings that tell OpenRouter to apply a series of transformations to the prompt before sending it to the model. Transformations are applied in-order
    # @param extras [Hash] Optional hash of model-specific parameters to send to the OpenRouter API
    # @param stream [Proc, nil] Optional callable object for streaming
    # @return [Hash] The completion response.
    def complete(messages, model: "openrouter/auto", providers: [], transforms: [], extras: {}, stream: nil)
      parameters = { messages: }
      if model.is_a?(String)
        parameters[:model] = model
      elsif model.is_a?(Array)
        parameters[:models] = model
        parameters[:route] = "fallback"
      end
      parameters[:provider] = { provider: { order: providers } } if providers.any?
      parameters[:transforms] = transforms if transforms.any?
      parameters[:stream] = stream if stream
      parameters.merge!(extras)

      puts parameters if Rails.env.local?

      json_post(path: "/chat/completions", parameters:).tap do |response|
        raise ServerError, "Empty response from OpenRouter. Might be worth retrying once or twice." if response.blank?
        raise ServerError, response.dig("error", "message") if response.dig("error", "message").present?
      end
    end

    # Fetches the list of available models from the OpenRouter API.
    # @return [Array<Hash>] The list of models.
    def models
      get(path: "/models")["data"]
    end

    # Queries the generation stats for a given id.
    # @param generation_id [String] The generation id returned from a previous request.
    # @return [Hash] The stats including token counts and cost.
    def query_generation_stats(generation_id)
      response = get(path: "/generation?id=#{generation_id}")
      response["data"]
    end
  end
end
