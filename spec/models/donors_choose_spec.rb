require 'spec_helper'

describe DonorsChoose do
  describe ".conn" do
    it "returns a Faraday connection" do
      Faraday.should_receive(:new).with({:url => "http://api.donorschoose.org"})
      DonorsChoose.conn
    end
  end

  describe ".get_proposals" do
    let(:conn) { double }
    let(:response) { double }

    before(:each) do 
      response.stub(:body).and_return('{"proposals":""}')
      DonorsChoose.stub(:conn).and_return(conn)
    end

    it "should make a get request to DonorsChoose" do
      conn.should_receive(:get).with("/common/json_feed.html?sortBy=3&max=2&costToCompleteRange=10+TO+20").and_return(response)
      DonorsChoose.get_proposals(20, 2)
    end

    it "should parse the JSON response" do
      conn.stub(:get).and_return(response)
      DonorsChoose.get_proposals(20, 2).should == ""
    end
  end

  describe ".set_inactive_projects" do
    it "sets all projects in the database to inactive" do
      Project.should_receive(:update_all).with({:active => false})
      DonorsChoose.set_inactive_projects
    end
  end

  describe ".set_active_projects" do
    let(:projects) { [ "1", "2" ] }
    it "calls to updates project status for each project" do
      DonorsChoose.should_receive(:update_project_status).with("1")
      DonorsChoose.should_receive(:update_project_status).with("2")
      DonorsChoose.set_active_projects(projects)
    end
  end

  describe ".update_project_status" do
    let(:project) { {:id => '1'} }
    let(:found_project) { Project.new }
    context "Given the project already exists" do
      it "updates the active status to true" do
        Project.stub(:find_by_external_id).and_return(found_project)
        found_project.should_receive(:update_attribute).with(:active, true)
        DonorsChoose.update_project_status(project)
      end
    end

    context "Given the project does not exist" do
      it "updates the active status to true" do
        DonorsChoose.stub(:clean_project_title).and_return("")
        Project.should_receive(:create)
        DonorsChoose.update_project_status(project)
      end
    end

  end
end