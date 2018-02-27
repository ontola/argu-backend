# frozen_string_literal: true

module RegexHelper
  EMAIL = /
    \A
    #{RFC822::Patterns::LOCAL_PT}
    \x40
    (?:(?:#{URI::REGEXP::PATTERN::DOMLABEL}\.)+#{URI::REGEXP::PATTERN::TOPLABEL}\.?)+#{RFC822::Patterns::ATOM}
    \z
  /x
end
