class Peng::Channels::Email
  class Mailer < ApplicationMailer
    def send_email
      data = params[:message]

      raise "The email should have :to and :from options" if data[:to].blank? || data[:from].blank? 

      mail({
        to: data[:to],
        from: data[:from],
        body: data[:body],
        content_type: "text/html",
        subject: data[:subject]
      })
    end
  end

  def self.address_method_name
    :email
  end

  def self.inline(message)
    Mailer.with(message: message).send_email.deliver_now
  end
  
  def self.async(message)
    Mailer.with(message: message).send_email.deliver_later
  end  
end