require_relative 'domain_config'

class NginxConfig
  OPTIONS        = %w(worker_connections debug)
  LISTEN_OPTIONS = " reuseport"

  def initialize(json = {})
    @domains = []

    if (json.keys - DomainConfig::OPTIONS - OPTIONS).any?
      listen_options = true
      json.each do |domain, domain_json|
        next if OPTIONS.include?(domain)
        if listen_options
          domain_json["listen_options"] = LISTEN_OPTIONS
          listen_options = false
        end
        @domains << DomainConfig.new(domain_json, domain)
      end
    else
      json["_"] = json.dup
      json.delete_if {|key, _| DomainConfig::OPTIONS.include?(key) }
      json["_"]["listen_options"] = LISTEN_OPTIONS
      @domains << DomainConfig.new(json["_"])
    end

    json["worker_connections"] ||= ENV["WORKER_CONNECTIONS"] || 512
    json["debug"] ||= ENV['STATIC_DEBUG']

    OPTIONS.each do |option|
      define_singleton_method(option) { json[option] }
    end
  end

  def each_domain(&block)
    return to_enum(:each_domain) if block.nil?
    @domains.each do |domain|
      domain.instance_eval(&block)
    end
  end

  def context
    binding
  end
end
