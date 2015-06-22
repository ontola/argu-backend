#
# Additional rules to determine which browsers need a polyfill
#
Browser.modern_rules.clear
Browser.modern_rules << -> b { (b.mobile? || b.tablet?) && !(b.chrome? || b.safari?) }
Browser.modern_rules << -> b { b.ie? && b.version.to_i > 10 }
Browser.modern_rules << -> b { !(b.mobile? && b.tablet?) && \
                                b.chrome?  && b.version.to_i > 41 || \
                                b.firefox? && b.version.to_i > 26 || \
                                b.opera?   && b.version.to_i > 26 || \
                                b.safari?  && b.full_version.to_f > 7.1 }
