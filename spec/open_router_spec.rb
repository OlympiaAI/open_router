# frozen_string_literal: true

RSpec.describe OpenRouter do
  it "has a version number" do
    expect(OpenRouter::VERSION).not_to be nil
  end

  describe OpenRouter::Client do
    let(:client) do
      OpenRouter::Client.new(access_token: ENV["ACCESS_TOKEN"]) do |config|
        config.faraday do |f|
          f.response :logger, ::Logger.new($stdout), { headers: true, bodies: true, errors: true } do |logger|
            logger.filter(/(Bearer) (\S+)/, '\1[REDACTED]')
          end
        end
      end
    end

    describe "#initialize" do
      it "yields the configuration" do
        expect { |b| OpenRouter::Client.new(&b) }.to yield_with_args(OpenRouter.configuration)
      end
    end

    describe "#complete" do
      let(:messages) { [{ role: "user", content: "What is the meaning of life?" }] }
      let(:extras) { { max_tokens: 100 } }

      it "sends a POST request to the completions endpoint with the correct parameters" do
        # let the call execute
        expect(client).to receive(:post).with(
          path: "/chat/completions",
          parameters: {
            model: "mistralai/mistral-7b-instruct:free",
            messages:,
            max_tokens: 100
          }
        ).and_call_original
        puts client.complete(messages, model: "mistralai/mistral-7b-instruct:free", extras:)
      end
    end

    describe "#models" do
      it "sends a GET request to the models endpoint" do
        expect(client).to receive(:get).with(path: "/models").and_return({ "data" => [] })
        client.models
      end

      it "returns the data from the response" do
        allow(client).to receive(:get).and_return({ "data" => [{ "id" => "model1" }, { "id" => "model2" }] })
        expect(client.models).to eq([{ "id" => "model1" }, { "id" => "model2" }])
      end
    end

    describe "#query_generation_stats" do
      let(:generation_id) { "generation_123" }

      it "sends a GET request to the generation endpoint with the generation ID" do
        expect(client).to receive(:get).with(path: "/generation?id=#{generation_id}").and_return({ "data" => {} })
        client.query_generation_stats(generation_id)
      end

      it "returns the data from the response" do
        allow(client).to receive(:get).and_return({ "data" => { "tokens" => 100, "cost" => 0.01 } })
        expect(client.query_generation_stats(generation_id)).to eq({ "tokens" => 100, "cost" => 0.01 })
      end
    end
  end
end
