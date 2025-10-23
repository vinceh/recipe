FactoryBot.define do
  factory :jwt_denylist do
    sequence(:jti) { |n| "jwt_token_#{n}_#{SecureRandom.hex(16)}" }
    exp { Time.current + 1.day }
  end
end
