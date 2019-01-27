class ApplicationMailer < ActionMailer::Base
  default from: 'from@example.com'
  layout 'mailer'

  def test
    @num = rand(1000)
    mail(to: "test@email.com", subject: "Test email - #{@num}")
  end

end
