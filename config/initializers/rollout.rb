require 'argu/redis'

$redis   = Argu::Redis.redis_instance
$rollout = Rollout.new($redis)

$rollout.define_group(:staff) do |user|
  user.profile.has_role? :staff
end

$rollout.define_group(:coders) do |user|
  user.profile.has_role? :coder
end
