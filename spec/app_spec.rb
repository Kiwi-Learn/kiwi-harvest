require_relative 'spec_helper'
require 'json'

describe 'Kiwi harvest Stories' do
  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
    @browser.goto 'localhost:9292'
  end

  describe 'Visiting the home page' do
    it 'finds the title' do
      @browser.title.must_equal 'Kiwi harvest'
    end
  end

  describe 'Search a course' do
    it 'can search a course' do
      @browser.link(text: 'Search').click
      @browser.url.must_match %r{http.*/search}

      @browser.text_field(name: 'keyword').set('program')
      @browser.input(id: 'check-submit').click
      @browser.url.must_match %r{http.*/courses/.*}

      @browser.table(class: 'table').rows.count.must_be :>=, 1
      @browser.table(class: 'table').rows[0].text.must_match(/Course ID/)
    end
  end

  describe 'List all courses' do
    it 'check courses list page and table' do
      @browser.link(text: 'Courses').click

      @browser.url.must_match %r{http.*/courses}

      @browser.table(class: 'table').rows.count.must_be :>=, 100
      @browser.table(class: 'table').rows[0].text.must_match(/Course ID/)
    end
  end

  # after do
  #   @browser.close
  #   @headless.destroy
  # end
end
