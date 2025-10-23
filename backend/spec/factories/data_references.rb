FactoryBot.define do
  factory :data_reference do
    reference_type { 'dietary_tag' }
    sequence(:key) { |n| "key_#{n}" }
    display_name { 'Display Name' }
  end
end
