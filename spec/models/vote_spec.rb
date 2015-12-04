require 'rails_helper'

RSpec.describe Vote, type: :model do
  it "vote numbers should increase after create a vote" do
    topic = Topic.create(title: "Moring!")
    vote = Vote.create(topic_id: topic.id, status: 1)
    expect(Vote.count).to eq 1
  end
end
