FactoryBot.define do
  factory :jwt_denylist do
    jti { "MyString" }
    exp { "2025-10-07 23:45:05" }
  end
end
