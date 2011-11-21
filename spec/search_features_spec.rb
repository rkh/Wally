require File.join(File.dirname(__FILE__), "spec_helper")
require "search_features"

describe SearchFeatures do
  include FakeFS::SpecHelpers

  before do
    FileUtils.mkdir "application-features"
  end

  def write_feature(name, contents)
    File.open("application-features/#{name}", "w") do |file|
      file.write(contents)
    end
  end

  it "finds features containing text" do
    write_feature("sample1.feature", "Feature: Bla")
    write_feature("sample2.feature", "Feature: Meh")

    results = SearchFeatures.new.find(:query => "Meh")
    results.size.should == 1
    results.first.matched_feature["name"].should == "Meh"
  end

  it "stores the original feature in the result" do
    write_feature("sample1.feature", "Feature: Bla")
    results = SearchFeatures.new.find(:query => "Bla")
    results.first.feature["name"].should == "Bla"
  end

  it "finds features containing text with any case" do
    write_feature("sample1.feature", "Feature: Bla")
    write_feature("sample2.feature", "Feature: Meh")

    results = SearchFeatures.new.find(:query => "MEH")
    results.size.should == 1
    results.first.matched_feature["name"].should == "Meh"
  end

  context "feature with multiple scenarios" do
    before do
      contents = <<-CONTENTS
        Feature: Sample Feature
        Scenario: Sample Scenario
        Scenario: Matched Scenario
          Given I do some things
        Scenario: Another Scenario
      CONTENTS
      write_feature("sample1.feature", contents)
    end

    it "finds scenarios containing text" do
      results = SearchFeatures.new.find(:query => "Matched SCENARIO")
      results.first.matched_scenarios.size.should == 1
      results.first.matched_scenarios.first["name"].should == "Matched Scenario"
    end

    it "finds scenario steps" do
      results = SearchFeatures.new.find(:query => "I DO SOME THINGS")
      results.first.matched_scenarios.size.should == 1
      results.first.matched_scenarios.first["name"].should == "Matched Scenario"
    end
  end
end
