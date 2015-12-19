require_relative 'domain_config'

class NginxConfig
  OPTIONS        = %w(worker_connections debug)
  LISTEN_OPTIONS = " reuseport"

  def initialize(json = {})
    @domains = []

    if json["configs"]
      listen_options = true

      json["configs"].each do |config|
        if listen_options
          config["listen_options"] = LISTEN_OPTIONS
          listen_options = false
        end
        @domains << DomainConfig.new(config)
      end
    else
      json["domains"] = ["_"]
      @domains << DomainConfig.new(json)
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
