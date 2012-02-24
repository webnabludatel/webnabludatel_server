Fabricator(:organization) do
  title { Faker::Company.name }
end

Fabricator(:user) do
  email { Faker::Internet.email }
  password "123456"
  password_confirmation "123456"
end

Fabricator(:watcher_referral) do
  user!
end

Fabricator(:commission) do
  number { rand(1000000) }
  address { Faker::Address.street_address }
end

Fabricator(:user_location) do
  user!
  commission!
end