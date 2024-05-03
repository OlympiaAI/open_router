# frozen_string_literal: true

module OpenRouter
  module HTTP
    def get(path:)
      conn.get(uri(path:)) do |req|
        req.headers = headers
      end&.body
    end

    def post(path:, parameters:)
      conn.post(uri(path:)) do |req|
        if parameters[:stream].respond_to?(:call)
          req.options.on_data = to_json_stream(user_proc: parameters[:stream])
          parameters[:stream] = true # Necessary to tell OpenRouter to stream.
        end

        req.headers = headers
        req.body = parameters.to_json
      end&.body
    end

    def multipart_post(path:, parameters: nil)
      conn(multipart: true).post(uri(path:)) do |req|
        req.headers = headers.merge({ "Content-Type" => "multipart/form-data" })
        req.body = multipart_parameters(parameters)
      end&.body
    end

    def delete(path:)
      conn.delete(uri(path:)) do |req|
        req.headers = headers
      end&.body
    end

    private

    # Given a proc, returns an outer proc that can be used to iterate over a JSON stream of chunks.
    # For each chunk, the inner user_proc is called giving it the JSON object. The JSON object could
    # be a data object or an error object as described in the OpenRouter API documentation.
    #
    # If the JSON object for a given data or error message is invalid, it is ignored.
    #
    # @param user_proc [Proc] The inner proc to call for each JSON object in the chunk.
    # @return [Proc] An outer proc that iterates over a raw stream, converting it to JSON.
    def to_json_stream(user_proc:)
      proc do |chunk, _|
        chunk.scan(/(?:data|error): (\{.*\})/i).flatten.each do |data|
          user_proc.call(JSON.parse(data))
        rescue JSON::ParserError
          # Ignore invalid JSON.
        end
      end
    end

    def conn(multipart: false)
      Faraday.new do |f|
        f.options[:timeout] = OpenRouter.configuration.request_timeout
        f.request(:multipart) if multipart
        f.use MiddlewareErrors if @log_errors
        f.response :raise_error
        f.response :json

        OpenRouter.configuration.faraday_config&.call(f)
      end
    end

    def uri(path:)
      File.join(OpenRouter.configuration.uri_base, OpenRouter.configuration.api_version, path)
    end

    def headers
      {
        "Authorization" => "Bearer #{OpenRouter.configuration.access_token}",
        "Content-Type" => "application/json"
      }.merge(OpenRouter.configuration.extra_headers)
    end

    def multipart_parameters(parameters)
      parameters&.transform_values do |value|
        next value unless value.is_a?(File)

        # Doesn't seem like OpenRouter needs mime_type yet, so not worth
        # the library to figure this out. Hence the empty string
        # as the second argument.
        Faraday::UploadIO.new(value, "", value.path)
      end
    end
  end
end
