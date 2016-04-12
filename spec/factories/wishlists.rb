FactoryGirl.define do
  factory :wishlist do
    title {Faker::Name.name}
    description  {Faker::Lorem.paragraph}
    price {Faker::Number.number(3)}

  end
end