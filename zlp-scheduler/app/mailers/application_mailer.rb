class ApplicationMailer < ActionMailer::Base
  # ToDo: setup the sender email and send verification email on send grid
  default from: ENV['SENDGRID_SENDER']
  layout 'mailer'
end
