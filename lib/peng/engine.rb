module Peng
  class Engine
    DEFAULT_CHANNELS = {
      email: Peng::Channels::Email
    }

    def initialize(data={})
      @data = data
    end
    
    def deliver(config)
      name_or_klass = config[:channel] || :mail
      channel_klass = name_or_klass.is_a?(Symbol) ? DEFAULT_CHANNELS[name_or_klass] : name_or_klass
      
      from = config[:from]

      if config[:to].is_a?(String)
        to = config[:to]        
      else
        address_method_name = config[:address_method_name].presence || channel_klass.address_method_name
        to = config[:to].public_send(address_method_name) 
        @data[:recipient] ||= config[:to]
      end    

      if config[:subject].present?
        subject = Mustache.render(config[:subject], @data)
      end
      if config[:body].present?        
        body    = Mustache.render(config[:body], @data)
      end

      message = {to: to, from: from, subject: subject, body: body}

      async = config.has_key?(:async) ? config[:async] : true

      async ? channel_klass.inline(message) : channel_klass.async(message) 
    end
  end
end