Given /^a feature file named "([^"]*)" with the contents:$/ do |filename, contents|
  @contents = contents
  create_feature_file(filename, @contents)
end

Then /^I should see a link to "([^"]*)" with the url "([^"]*)"$/ do |text, url|
  page.should have_link text, :href => url
end
