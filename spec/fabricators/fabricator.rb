Fabricator(:organization) do
  title { Faker::Company.name }
end

Fabricator(:user) do
  email { Faker::Internet.email }
  password "123456"
  password_confirmation "123456"
end

Fabricator(:watcher_referal) do
  user!
end
