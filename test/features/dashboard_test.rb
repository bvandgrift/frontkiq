# encoding: utf-8
require 'test_helper'
require 'frontkiq'

# setup

feature "dashboard" do
  scenario "loads" do
    visit frontkiq_root_path # frontkiq_dashboard_path
    page.must_have_content "Dashboard"
  end
end
