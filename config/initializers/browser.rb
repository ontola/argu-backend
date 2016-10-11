# frozen_string_literal: true
#
# Additional rules to determine which browsers need a polyfill
#
Browser.modern_rules.clear
Browser.modern_rules << lambda do |b|
  (b.mobile? || b.tablet?) && (b.chrome? && b.version.to_i >= 51 || b.safari? && b.version.to_i >= 9.1)
end
# Browser.modern_rules << -> b { !b.ie? } # IE11 doesn't support Promise/A+
Browser.modern_rules << lambda do |b|
  !(b.mobile? && b.tablet?) && \
    b.chrome?  && b.version.to_i >= 51 || \
    b.firefox? && b.version.to_i >= 47 || \
    b.opera?   && b.version.to_i >= 38 || \
    b.safari?  && b.full_version.to_f >= 9.1
end
