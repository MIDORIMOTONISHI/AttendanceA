# coding: utf-8

User.create!(name: "管理者",
             email: "admin@email.com",
             password: "password",
             password_confirmation: "password",
             admin: true)
             
User.create!(name: "上長A",
             email: "boss_a@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)
             
User.create!(name: "上長B",
             email: "boss_b@email.com",
             password: "password",
             password_confirmation: "password",
             superior: true)

60.times do |n|
  name  = Faker::Name.name
  email = "sample-#{n+1}@email.com"
  password = "password"
  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end