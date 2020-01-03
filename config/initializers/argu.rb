# frozen_string_literal: true

Dir['lib/argu/*.rb'].each { |file| require file.sub('lib/', '') }
