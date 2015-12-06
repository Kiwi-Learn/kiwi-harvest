require 'page-object'

class HomePage
  include PageObject

  page_url "http://localhost:9292"

  link(:home_link, text: 'Home')
  link(:kiwi_learn_link, text: 'Kiwi Learn')
  link(:search_link, text: 'Search')
  link(:courses_link, text: 'Courses')
  h1(:homepage_header)

  def click_home_link
    home_link
  end

  def click_kiwi_learn_link
    kiwi_learn_link
  end

end
