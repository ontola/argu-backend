# frozen_string_literal: true

require 'argu/redis'

$redis   = Argu::Redis.redis_instance
$rollout = Rollout.new($redis)

$rollout.define_group(:staff, &:is_staff?)
