FactoryGirl.define do
  factory :resource do
    name { Faker::Vehicle.manufacture }
    quantity { 10 }
    used { 5 }
    conference
  end
end
