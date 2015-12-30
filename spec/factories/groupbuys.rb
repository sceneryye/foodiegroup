FactoryGirl.define do
  factory :groupbuy do
    title {Faker::Name.name}
    pic_url {Faker::Avatar.image}
    body  {Faker::Lorem.paragraph}
    start_time {Faker::Date.between(12.days.ago, 5.days.ago)}
    end_time {Faker::Date.backward(14)}
    goods_unit 'kg'
    price {Faker::Number.number(3)}
    goods_minimal 1
    locale 'zh'
  end
end
