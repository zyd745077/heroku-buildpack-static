require 'uri'
require_relative 'nginx_config_util'

class DomainConfig
  OPTIONS = %w(
    clean_urls
    domains
    encoding
    error_page
    headers
    https_only
    port
    proxies
    redirects
    root
    routes
  )

  def initialize(json = {})
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
    json["domains"] ||= ["_"]

    (OPTIONS + ["listen_options"]).each do |option|
      define_singleton_method(option) { json[option] }
    end
  end
end
