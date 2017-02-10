FactoryGirl.define do
  factory :resource do
    name { 'resource' }
    quantity { 10 }
    used { 5 }
    conference
  end
end
