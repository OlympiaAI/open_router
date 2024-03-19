# OpenRouter

The future will bring us hundreds of language models and dozens of providers for each. How will you choose the best?

The [OpenRouter API](https://openrouter.ai/docs) is a single unified interface for all LLMs! And now you can easily use it with Ruby! 🤖🌌

## Features

- **Prioritize price or performance**: OpenRouter scouts for the lowest prices and best latencies/throughputs across dozens of providers, and lets you choose how to prioritize them.
- **Standardized API**: No need to change your code when switching between models or providers. You can even let users choose and pay for their own.
- **Easy integration**: This Ruby gem provides a simple and intuitive interface to interact with the OpenRouter API, making it effortless to integrate AI capabilities into your Ruby applications.

👬 This Ruby library was originally bootstrapped from the [🤖 Anthropic](https://github.com/alexrudall/anthropic) gem by Alex Rudall, and subsequently extracted from the codebase of my fast-growing AI startup called [Olympia](https://olympia.chat?utm_source=open_router_gem&utm_medium=github) that lets you add AI-powered consultants to your startup!

🚢 Need someone to develop AI software for you using modern Ruby on Rails? My other company Magma Labs does exactly that: [magmalabs.io](https://www.magmalabs.io/?utm_source=open_router_gem&utm_medium=github). In fact, we also sell off-the-shelf solutions based on my early work on the field, via a platform called [MagmaChat](https://magmachat.ai?utm_source=open_router_gem&utm_medium=github)


[🐦 Olympia's Twitter](https://twitter.com/OlympiaChat) | [🐦 Obie's Twitter](https://twitter.com/OlympiaChat) | [🎮 Ruby AI Builders Discord](https://discord.gg/k4Uc224xVD)

### Bundler

Add this line to your application's Gemfile:

```ruby
gem "open_router"
```

And then execute:

$ bundle install

### Gem install

Or install with:

$ gem install open_router

and require with:

```ruby
require "open_router"
```

## Usage

- Get your API key from [https://openrouter.ai/keys](https://openrouter.ai/keys)

### Quickstart

Configure the gem with your API keys, for example in an `open_router.rb` initializer file. Never hardcode secrets into your codebase - instead use `Rails.application.credentials` or something like [dotenv](https://github.com/motdotla/dotenv) to pass the keys safely into your environments.

```ruby
OpenRouter.configure do |config|
  config.access_token = Rails.application.credentials.open_router[:access_token]
  config.site_name = 'Olympia'
  config.site_url = 'https://olympia.chat'
end
```

Then you can create a client like this:

```ruby
client = OpenRouter::Client.new
```

#### Change version or timeout

The default timeout for any request using this library is 120 seconds. You can change that by passing a number of seconds to the `request_timeout` when initializing the client.

```ruby
client = OpenRouter::Client.new(
    access_token: "access_token_goes_here",
    request_timeout: 240 # Optional
)
```

### Completions

Hit the OpenRouter API for a completion:

```ruby
messages = [
  { role: "system", content: "You are a helpful assistant." },
  { role: "user", content: "What is the color of the sky?" }
]

response = client.complete(messages)
puts response["choices"][0]["message"]["content"]
# => "The sky is typically blue during the day due to a phenomenon called Rayleigh scattering. Sunlight..."
```

### Models

Fetch the list of available models from the OpenRouter API:

```ruby
models = client.models
puts models
# => [{"id"=>"openrouter/auto", "object"=>"model", "created"=>1684195200, "owned_by"=>"openrouter", "permission"=>[], "root"=>"openrouter", "parent"=>nil}, ...]
```

### Query Generation Stats

Query the generation stats for a given generation ID:

```ruby
generation_id = "generation-abcdefg"
stats = client.query_generation_stats(generation_id)
puts stats
# => {"id"=>"generation-abcdefg", "object"=>"generation", "created"=>1684195200, "model"=>"openrouter/auto", "usage"=>{"prompt_tokens"=>10, "completion_tokens"=>50, "total_tokens"=>60}, "cost"=>0.0006}
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/OlympiaAI/open_router>. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/OlympiaAI/open_router/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
