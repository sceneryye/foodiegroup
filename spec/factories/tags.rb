FactoryGirl.define do
  factory :tag do
    name {Faker::Name.name}
    url {Faker::Internet.url}
    rate {Faker::Number.between(1, 10)}
  end
end
