require 'uri'
require_relative 'nginx_config_util'

class DomainConfig
  OPTIONS = %w(port root encoding proxies clean_urls https_only routes redirects error_page headers)

  attr_reader :domain

  def initialize(json = {}, domain = "_")
    @domain = domain

    json["port"] ||= ENV["PORT"] || "5000"
    json["root"] ||= "public_html/"
    json["encoding"] ||= "UTF-8"
    json["proxies"] ||= {}
    json["proxies"].each do |loc, hash|
      if hash["origin"][-1] != "/"
        json["proxies"][loc].merge!("origin" => hash["origin"] + "/")
      end

      uri = URI(hash["origin"])
      json["proxies"][loc]["path"] = uri.path
      uri.path = ""
      json["proxies"][loc]["host"] = uri.to_s
    end
    json["clean_urls"] ||= false
    json["https_only"] ||= false
    json["routes"] ||= {}
    json["routes"] = NginxConfigUtil.parse_routes(json["routes"])
    json["redirects"] ||= {}
    json["error_page"] ||= nil

    (OPTIONS + ["listen_options"]).each do |option|
      define_singleton_method(option) { json[option] }
    end
  end
end
