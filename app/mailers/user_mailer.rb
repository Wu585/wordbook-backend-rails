class UserMailer < ApplicationMailer
  def welcome_email(code)
    @code = code
    mail(to: '15151851516@163.com', subject: 'Hi!')
  end
end
