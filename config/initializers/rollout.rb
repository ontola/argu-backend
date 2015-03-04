require 'redis'

$redis   = Redis.new
$rollout = Rollout.new($redis)

$rollout.define_group(:staff) do |user|
  user.profile.has_role? :staff
end

$rollout.define_group(:coders) do |user|
  user.profile.has_role? :coder
end
