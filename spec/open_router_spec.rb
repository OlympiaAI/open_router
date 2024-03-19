# frozen_string_literal: true

# frozen_string_literal: true
RSpec.describe OpenRouter do
  it "has a version number" do
    expect(OpenRouter::VERSION).not_to be nil
  end

  describe OpenRouter::Client do
    let(:client) { OpenRouter::Client.new }

    describe "#initialize" do
      it "yields the configuration" do
        expect { |b| OpenRouter::Client.new(&b) }.to yield_with_args(OpenRouter.configuration)
      end
    end

    describe "#complete" do
      let(:messages) { [{ role: "user", content: "What is the meaning of life?" }] }
      let(:model) { "openrouter/auto" }
      let(:providers) { ["provider1", "provider2"] }
      let(:transforms) { ["transform1", "transform2"] }
      let(:extras) { { max_tokens: 100 } }
      let(:stream) { proc { |response| } }

      it "sends a POST request to the completions endpoint with the correct parameters" do
        expect(client).to receive(:json_post).with(
          path: "/chat/completions",
          parameters: {
            model: model,
            messages: messages,
            provider: { provider: { order: providers } },
            transforms: transforms,
            stream: stream,
            max_tokens: 100
          }
        )
        client.complete(messages, model: model, providers: providers, transforms: transforms, extras: extras, stream: stream)
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
