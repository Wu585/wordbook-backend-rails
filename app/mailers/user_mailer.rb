class UserMailer < ApplicationMailer
  def welcome_email(email)
    validation_code = ValidationCode.find_by_email email
    @code = validation_code.code
    mail(to: email, subject: 'WordBook验证码!')
  end
end
