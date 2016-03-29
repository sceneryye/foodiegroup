FactoryGirl.define do
  factory :comment do
    body {Faker::Lorem.paragraph}
    factory :groupbuy_comment do
      groupbuy_id 1
    end
  end
end

