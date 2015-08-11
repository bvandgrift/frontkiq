# encoding: utf-8
require 'test_helper'
require 'frontkiq'

# setup

feature "/queued_jobs" do
  scenario "loads" do
    visit frontkiq_queued_jobs_path # frontkiq_dashboard_path
    page.must_have_content "Queued Jobs"
  end
end
