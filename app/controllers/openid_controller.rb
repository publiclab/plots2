require 'pathname'

require 'openid'
require 'openid/consumer/discovery'
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

class OpenidController < ApplicationController
  # protect_from_forgery :except => [:index]

  include OpenidHelper
  include OpenID::Server
  layout nil

  def index
    begin
      permitted_params = params.permit(
        'authenticity_token', 'back_to',
        'commit',
        'open_id', 'openid.assoc_handle',
        'openid.op_endpoint',
        'openid.response_nonce',
        'openid.sig', 'openid.signed',
        'openid.sreg.email',
        'openid.sreg.fullname', # fullname contains both status and role
        'openid.sreg.nickname',
        'return_to', 'openid.claimed_id',
        'openid.identity', 'openid.mode',
        'openid.ns', 'openid.ns.sreg',
        'openid.realm', 'openid.return_to',
        'openid.sreg.required',
        'openid.trust_root',
        'openid.id_select',
        'openid.immediate',
        'openid.cancel_url'
      ).to_h
      oidreq = if params['openid.mode']
                 server.decode_request(permitted_params)
               else
                 server.decode_request(Rack::Utils.parse_query(request.env['ORIGINAL_FULLPATH'].split('?')[1]))
               end
    rescue ProtocolError => e
      # invalid openid request, so just display a page with an error message
      render plain: e.to_s, status: 500
      return
    end

    # no openid.mode was given
    unless oidreq
      render plain: 'This is an OpenID server endpoint.'
      return
    end

    requested_credentials = ''
    requested_username = ''
    provider = nil

    if request.env['ORIGINAL_FULLPATH']&.split('?')[1]
      request.env['ORIGINAL_FULLPATH'].split('?')[1].split('&').each do |param|
        requested_credentials = param.split('=')[1].split('%2F') if param.split('=')[0] == 'openid.claimed_id'
      end
    end

    # ORIGINAL_FULLPATH will be like https://publiclab.org/openid/:username(/:provider)
    # so we need to get the username for sure and the provider if it exists
    # requested_credentials contains array of the ORIGINAL_FULLPATH striped with '/' symbol
    if requested_credentials && requested_credentials[-3] == 'openid'
      requested_username = requested_credentials[-2]
      provider = requested_credentials[-1]
    else
      provider = nil
      requested_username = requested_credentials[-1]
    end

    if current_user.nil? && params['openid.mode'] != 'check_authentication'
      session[:openid_return_to] = request.env['ORIGINAL_FULLPATH']
      if provider
        # authentication through the provider
        redirect_to '/auth/' + provider
      else
        # form based authentication
        flash[:warning] = 'Please log in first.'
        redirect_to '/login'
      end
      return
    else

      if oidreq


        oidresp = nil
        if oidreq.is_a?(CheckIDRequest)

            identity = oidreq.identity

            if oidreq.id_select
              if oidreq.immediate
                oidresp = oidreq.answer(false)
              elsif session[:username]
                # The user hasn't logged in.
                # show_decision_page(oidreq) # this doesnt make sense... it was in the example though
                session[:openid_return_to] = request.env['ORIGINAL_FULLPATH']
                if provider
                  # provider based authentication
                  redirect_to '/auth/' + provider
                else
                  # form based authentication
                  redirect_to '/login'
                end
              else
                # Else, set the identity to the one the user is using.
                identity = url_for_user
              end

            end

            if oidresp
              nil
            elsif is_authorized(identity, oidreq.trust_root)
              oidresp = oidreq.answer(true, nil, identity)

              # add the sreg response if requested
              add_sreg(oidreq, oidresp)
              # ditto pape
              add_pape(oidreq, oidresp)

            elsif oidreq.immediate
              server_url = url_for action: 'index'
              oidresp = oidreq.answer(false, server_url)

            else
              session[:last_oidreq] = oidreq
              @oidreq = oidreq
              redirect_to action: 'decision'
              return
            end

        else
            oidresp = server.handle_request(oidreq)
          end

        render_response(oidresp)
      else
        session[:openid_return_to] = request.env['ORIGINAL_FULLPATH']
        if provider
          # provider based authentication
          redirect_to '/auth/' + provider
        else
          # form based authentication
          redirect_to '/login'
        end
      end
    end
  end

  def resume
    if session[:openid_return_to] # for openid login, redirects back to openid auth process
      return_to = session[:openid_return_to]
      session[:openid_return_to] = nil
      session[:openid_requester] = nil
      redirect_to return_to
    end
  end

  def show_decision_page(oidreq, message = '')
    session[:last_oidreq] = oidreq
    @oidreq = oidreq

    flash.now[:notice] = message if message

    render template: 'openid/decide'
  end

  def user_page
    # Yadis content-negotiation: we want to return the xrds if asked for.
    accept = request.env['HTTP_ACCEPT']

    # This is not technically correct, and should eventually be updated
    # to do real Accept header parsing and logic.  Though I expect it will work
    # 99% of the time.
    if accept&.include?('application/xrds+xml')
      user_xrds
      return
    end

    # content negotiation failed, so just render the user page
    xrds_url = url_for(controller: 'user', action: params[:username]) + '/xrds'
    identity_page = <<~HTML
      <html><head>
      <meta http-equiv="X-XRDS-Location" content="#{xrds_url}" />
      <link rel="openid.server" href="#{url_for action: 'index'}" />
      </head><body><p>OpenID identity page for #{params[:username]}</p>
      </body></html>
    HTML

    # Also add the Yadis location header, so that they don't have
    # to parse the html unless absolutely necessary.
    response.headers['X-XRDS-Location'] = xrds_url
    render plain: identity_page
  end

  def user_xrds
    types = [
      OpenID::OPENID_2_0_TYPE,
      OpenID::OPENID_1_0_TYPE,
      OpenID::SREG_URI
    ]

    render_xrds(types)
  end

  def idp_xrds
    types = [
      OpenID::OPENID_IDP_2_0_TYPE
    ]

    render_xrds(types)
  end

  def decision
    oidreq = session[:last_oidreq]
    session[:last_oidreq] = nil
    id_to_send = params[:id_to_send]
    identity = oidreq&.identity
    if oidreq.id_select
      if id_to_send && (id_to_send != '')
        session[:username] = id_to_send
        session[:approvals] = []
        identity = url_for_user
      else
        msg = 'You must enter a username to in order to send ' \
              'an identifier to the Relying Party.'
        show_decision_page(oidreq, msg)
        return
      end
    else
      session[:username] = current_user.username
    end

    if session[:approvals]
      session[:approvals] << oidreq.trust_root
    else
      session[:approvals] = [oidreq.trust_root]
    end
    oidresp = oidreq.answer(true, nil, identity)
    add_sreg(oidreq, oidresp)
    add_pape(oidreq, oidresp)
    return render_response(oidresp)
  end

  protected

  def server
    if @server.nil?
      server_url = url_for action: 'index', only_path: false
      dir = Pathname.new(request.host).join('db').join('openid-store')
      store = OpenID::Store::Filesystem.new(dir)
      @server = Server.new(store, server_url)
    end
    @server
  end

  def approved(trust_root)
    return false if session[:approvals].nil?

    session[:approvals].member?(trust_root)
  end

  def is_authorized(identity_url, trust_root)
    (session[:username] && (identity_url == url_for_user) && approved(trust_root))
  end

  def render_xrds(types)
    type_str = ''

    types.each do |uri|
      type_str += "<Type>#{uri}</Type>\n      "
    end

    yadis = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <xrds:XRDS
          xmlns:xrds="xri://$xrds"
          xmlns="xri://$xrd*($v*2.0)">
        <XRD>
          <Service priority="0">
            #{type_str}
            <URI>#{url_for(controller: 'openid', only_path: false)}</URI>
          </Service>
        </XRD>
      </xrds:XRDS>
    XML

    response.headers['content-type'] = 'application/xrds+xml'
    render plain: yadis
  end

  def add_sreg(oidreq, oidresp)
    # check for Simple Registration arguments and respond
    sregreq = OpenID::SReg::Request.from_openid_request(oidreq)

    return if sregreq.nil?

    # In a real application, this data would be user-specific,
    # and the user should be asked for permission to release
    # it.
    sreg_data = {
      'nickname' => current_user.username, # session[:username],
      'email' => current_user.email,
      'fullname' => "status=" + current_user.status.to_s + ":role=" + current_user.role # fullname contains both status and role
    }

    sregresp = OpenID::SReg::Response.extract_response(sregreq, sreg_data)
    oidresp.add_extension(sregresp)
  end

  def add_pape(oidreq, oidresp)
    papereq = OpenID::PAPE::Request.from_openid_request(oidreq)
    return if papereq.nil?

    paperesp = OpenID::PAPE::Response.new
    paperesp.nist_auth_level = 0 # we don't even do auth at all!
    oidresp.add_extension(paperesp)
  end

  def render_response(oidresp)
    server.signatory.sign(oidresp) if oidresp.needs_signing
    web_response = server.encode_response(oidresp)
    case web_response.code
    when HTTP_OK
      render plain: web_response.body, status: 200

    when HTTP_REDIRECT
      redirect_to web_response.headers['location']

    else
      render plain: web_response.body, status: 400
    end
  end
end
