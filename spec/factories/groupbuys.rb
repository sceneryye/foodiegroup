FactoryGirl.define do
  factory :groupbuy do
    en_title {Faker::Name.name}
    zh_title {Faker::Name.name}
    pic_url {Faker::Avatar.image}
    en_body  {Faker::Lorem.paragraph}
    zh_body  {Faker::Lorem.paragraph}
    start_time {Faker::Date.between(12.days.ago, 5.days.ago)}
    end_time {Faker::Date.forward(14)}
    goods_unit 'kg'
    price {Faker::Number.number(3)}
    market_price 10
    groupbuy_price 2
    goods_minimal 1
    goods_maximal 100
    locale 'zh'
    
  end
end
