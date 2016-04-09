#
# Additional rules to determine which browsers need a polyfill
#
Browser.modern_rules.clear
Browser.modern_rules << lambda do |b|
  (b.mobile? || b.tablet?) && (b.chrome? && b.version.to_i > 41 || b.safari? && b.version.to_i > 7)
end
# Browser.modern_rules << -> b { !b.ie? } # IE11 doesn't support Promise/A+
Browser.modern_rules << lambda do |b|
  !(b.mobile? && b.tablet?) && \
    b.chrome?  && b.version.to_i > 41 || \
    b.firefox? && b.version.to_i > 26 || \
    b.opera?   && b.version.to_i > 26 || \
    b.safari?  && b.full_version.to_f > 7.1
end
