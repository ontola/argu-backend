

class Argu::TestCase < ActionController::TestCase

  def self.test(name, options = {}, &block)
    if options[:tenant].present?
      super(name,
            &Proc.new {
              tenant = get_tenant_from_block(options[:tenant], &block)
              Apartment::Tenant.switch(tenant_name(tenant)) do
                instance_eval(&block)
              end
            })
    else
      super(name, &block)
    end
  end

  private

  def get_tenant_from_block(tenant_sym, &block)
    self.send tenant_sym
  end

  def tenant_name(tenant)
    tenant.to_param
  end
end
