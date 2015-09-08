

class Argu::TestCase < ActionController::TestCase

  def self.test(name, options = {}, &block)
    if options[:tenant].present?
      tenant_switch_wrapper = -> (tenant_sym, &block) {
        return Proc.new {
          tenant = get_tenant_from_block(tenant_sym, &block)
          Apartment::Tenant.switch(tenant_name(tenant)) do
            yield block
          end
        }
      }
      val = tenant_switch_wrapper.call(options[:tenant], &block)
      super(name, &val)
    else
      super(name, &block)
    end
  end

  def get_tenant_from_block(tenant_sym, &block)
    self_in_block = eval 'self', block.binding
    self_in_block.send tenant_sym
  end

  private

  def tenant_name(tenant)
    tenant.to_param
  end

end
