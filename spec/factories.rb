FactoryGirl.define do
  factory :user do
    name     "Lucas Fleming"
    email    "lfleming@example.com"
    password "foobar"
    password_confirmation "foobar"
  end
end
