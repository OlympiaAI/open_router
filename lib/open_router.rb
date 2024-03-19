# frozen_string_literal: true

require "faraday"
require "faraday/multipart"

require_relative "open_router/http"
require_relative "open_router/client"
require_relative "open_router/version"

module OpenRouter
  class Error < StandardError; end
  class ConfigurationError < Error; end

  class Configuration
    attr_writer :access_token
    attr_accessor :api_version, :extra_headers, :request_timeout, :uri_base

    DEFAULT_API_VERSION = "v1"
    DEFAULT_REQUEST_TIMEOUT = 120
    DEFAULT_URI_BASE = 'https://openrouter.ai/api'

    def initialize
      @access_token = nil
      @uri_base = DEFAULT_URI_BASE
      @api_version = DEFAULT_API_VERSION
      @request_timeout = DEFAULT_REQUEST_TIMEOUT
      @extra_headers = {}
    end

    def access_token
      return @access_token if @access_token

      raise ConfigurationError, "OpenRouter access token missing!"
    end

    def site_name=(value)
      @extra_headers["X-Title"] = value
    end

    def site_url=(value)
      @extra_headers["HTTP-Referer"] = value
    end
  end

  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= OpenRouter::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
