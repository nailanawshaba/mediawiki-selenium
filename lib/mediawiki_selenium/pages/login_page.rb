require 'page-object'

class LoginPage
  include PageObject

  page_url 'Special:UserLogin'

  div(:feedback, class: 'errorbox')
  button(:login, id: 'wpLoginAttempt')
  li(:logout, id: 'pt-logout')
  text_field(:password, id: 'wpPassword1')
  a(:password_strength, text: 'password strength')
  a(:phishing, text: 'phishing')
  text_field(:username, id: 'wpName1')
  a(:username_displayed, title: /Your user page/)

  def logged_in_as_element
    @browser.div(id: 'mw-content-text').p.b
  end

  def login_with(username, password, wait_for_logout_element = true)
    username_element.send_keys(username)
    password_element.send_keys(password)
    login_element.click
    logout_element if wait_for_logout_element
  end
end
