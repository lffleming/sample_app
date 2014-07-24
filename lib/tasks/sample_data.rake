
namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    make_users
    make_microposts
    make_relationships
  end
end

def make_users
  admin = User.create!(name:     "Example User",
                      username: "exampleuser",
                      email:    "example@railstutorial.org",
                      password: "foobar",
                      password_confirmation: "foobar",
                      admin: true,
                      state: "active",
                      notification: false)
  99.times do |n|
    name  = Faker::Name.name
    username = "example-#{n+1}"
    email = "example-#{n+1}@railstutorial.org"
    password  = "password"
    User.create!(name:     name,
                username: username,
                email:    email,
                password: password,
                state: "active",
                password_confirmation: password,
                notification: false)
  end
end

def make_microposts
  users = User.all(limit: 6)
  50.times do
    content = Faker::Lorem.sentence(5)
    users.each { |user| user.microposts.create!(content: content) }
  end
end

def make_relationships
  users = User.all
  user  = users.first
  followed_users = users[2..50]
  followers      = users[3..40]
  followed_users.each { |followed| user.follow!(followed) }
  followers.each      { |follower| follower.follow!(user) }
end
