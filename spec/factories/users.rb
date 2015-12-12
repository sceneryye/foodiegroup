FactoryGirl.define do
  factory :user do
    sequence(:name) {|n| "who#{n}"}
    sequence(:username) {|n| "whom#{n}"}
    group_id 1
    role '0'
    password '123456789'
    sequence(:mobile) {|n|"1311311311#{n}"}

    factory :admin do
      role '1'      
    end
  end
end