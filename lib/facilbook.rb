require "facilbook/version"

module Facilbook

  module Rack
    class Facebook
      
      def initialize(app)
        @app = app
      end

      def call(env)
        request = ::Rack::Request.new(env)
        
        if request.POST['signed_request']
          env["REQUEST_METHOD"] = 'GET'
        end

        return @app.call(env)
      end
    end
  end

  module ApplicationHelperMethods
    
    def facebook_image_tag(uid, options = {})
      options.symbolize_keys!
      image_url = "https://graph.facebook.com/#{uid}/picture"
      if options[:type] && (['square','small','large'].include? options[:type])
        image_url << "?type=#{options[:type]}"
      end
      
      src = image_url
      options[:src] = src
      
      unless src =~ /^cid:/
        options[:alt] = options.fetch(:alt){ File.basename(src, '.*').capitalize }
      end
      if size = options.delete(:size)
        options[:width], options[:height] = size.split("x") if size =~ %{^\d+x\d+$}
      end
      tag("img", options)
    end
    
    def link_to_facebook(*args, &block)
      html_options = args.extract_options!.symbolize_keys
      # logger.debug "OPTIONS: #{html_options.inspect}"
      name = args[0]
      path = block_given? ? update_page(&block) : args[1] || ''
      tag_class = html_options[:class] ||= ''
      onclick = "window.top.location='#{FACILBOOK_CONFIG[:facebook_app_url]}#{path}'; return false;"
      content_tag(:a, name, html_options.merge(:href => '#', :onclick => onclick, :class => tag_class))
    end

    def url_for_facebook(path)
      "#{FACILBOOK_CONFIG[:facebook_app_url]}#{path}"
    end
    
  end
    
  module ApplicationControllerMethods
    
    def self.included(klass)
      klass.class_eval do
        before_filter :parse_signed_request
        helper_method :current_user
      end
    end
    
    protected

    # Note - *args is ignored
    def redirect_to_facebook(target_path, *args)
      raise ActionControllerError.new("Cannot redirect to nil!") if target_path.nil?
      raise ActionControllerError.new("Must use path and not url as target") if target_path =~ /^http/
      url = "#{FACILBOOK_CONFIG[:facebook_app_url]}#{target_path}"
      render :text => "<html><body><script type=\"text/javascript\">window.top.location='#{url}';</script></body></html>"
    end

    def parse_signed_request
      # IE6-7 fix
      response.headers['P3P'] = 'CP="IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT"'

      # Get the signed request from either the request or the cookie
      signed_request = get_signed_cookie(params[:signed_request])

      if signed_request
        encoded_sig, payload = signed_request.split(".")
        sig = base64_url_decode(encoded_sig)

        # Ensure that the request is valid from Facebook
        if OpenSSL::HMAC.digest("sha256", FACILBOOK_CONFIG[:app_secret], payload) == sig

          decoded = base64_url_decode(payload)
          @signed_request = JSON.parse(decoded)
          @signed_request['signed_request_provided'] = params[:signed_request].present?
          puts "Current Signed Request: #{@signed_request.to_yaml}"

        else
          logger.info "SIGNED REQUEST AND SIGNATURE DO NOT MATCH!!!"
          @signed_request = nil
        end

      else
        logger.info "NO SIGNED REQUEST!!! THIS IS NOT VIA FACEBOOK!!!"
      end
    end

    def current_user
      begin
        if session[:user_id]
          @current_user = User.find(session[:user_id])
        elsif @signed_request && @signed_request['user_id']
          @current_user = User.where(:provider => 'facebook').where(:uid => @signed_request['user_id']).first
        else
          @current_user = nil
        end
      rescue ActiveRecord::RecordNotFound => ex
        @current_user = nil
      end
    end

    # This takes the signed request and places it into a cookie and returns the 
    # signed_request from the cookie. If the signed_request is not provided, it
    # will still return the signed_request placed in the cookie previously.
    # @param [String] signed_request Signed request from Facebook
    # @returns [String] Signed request from cookie
    #
    def get_signed_cookie(signed_request)
      if signed_request
        cookies["sr_#{FACILBOOK_CONFIG[:app_id]}"] = params[:signed_request]
      else
        signed_request = cookies["sr_#{FACILBOOK_CONFIG[:app_id]}"]
      end
      return signed_request
    end

    # Facebook uses a special base64 encryption. This decodes it.
    # @param [String] encoded_sig Encoded string
    # @returns [String] Decoded string
    #
    def base64_url_decode(str)
      if !str.blank?
        str += '=' * (4 - str.length.modulo(4))
        Base64.decode64(str.tr('-_','+/'))
      else
        nil
      end
    end

    # Create a url that points to the Facebook representation of a local path
    # @param [String] path
    # @returns [String] URL pointing to the facebook url with the local path
    #
    def url_for_facebook(path)
      base_url = FACILBOOK_CONFIG[:facebook_app_url]
      obfuscated_path = Obfuscator.encrypt_string(path, 'm0n3ym@k3r')
      return "#{FACILBOOK_CONFIG[:facebook_app_url]}/#{path}"
    end
    
  end
end
