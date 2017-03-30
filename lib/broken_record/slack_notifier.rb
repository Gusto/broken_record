require 'net/http'
module BrokenRecord
  class SlackNotifier
    def initialize(initial_options)
      @options = default_options
      @options = @options.merge(initial_options)
      @options = @options.merge(BrokenRecord::Config.slack_options)
    end

    def send!(message)
      return unless @options[:summary]
      if defined?(Rails) && Rails.env.development?
        puts message
      else
        slack_params = @options.merge(text: message)
        uri = URI('https://slack.com/api/chat.postMessage')
        uri.query = URI.encode_www_form(slack_params)
        Net::HTTP.get(uri)
      end
    end

    def

    private

    def default_options
      {
        token: slack_token,
        channel: '#eng-viking-master',
        parse: 'none',
        link_names: '1',
        pretty: '1',
        username: 'ValidationMaster',
        icon_emoji: ':llama:',
        summary: true
      }
    end

    def slack_token
      ENV['SLACK_API_TOKEN']
    end
  end
end
