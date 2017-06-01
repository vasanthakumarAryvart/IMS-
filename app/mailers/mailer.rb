class Mailer < ActionMailer::Base
  # todo - support proper env setup
  default from: 'Clarabyte No-Reply <no-reply@clarabyte.com>'

  def notification(n)
    @notification = n
    mail :to => n.user.email,
         :subject => n.title
  end
end
