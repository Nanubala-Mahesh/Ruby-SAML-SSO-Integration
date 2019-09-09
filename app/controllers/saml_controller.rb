require 'onelogin/ruby-saml'

class SamlController < ApplicationController
  skip_before_action :verify_authenticity_token

  def init
    request = OneLogin::RubySaml::Authrequest.new
    redirect_to(request.create(saml_settings))
  end

  def consume
    response = OneLogin::RubySaml::Response.new(params[:SAMLResponse])

    response.settings = saml_settings
    puts "response: #{response}"

    puts "response.attributes: #{response.attributes.as_json}"
    if response.is_valid?
      attributes = response.attributes
      email = response.name_id
      first_name = attributes[:FirstName]
      last_name = attributes[:LastName]
      User.find_or_create_by(email: email, first_name: first_name, last_name: last_name)

      session[:authenticated] = true
      session[:email] = email
      redirect_to products_path
    else
      render json: 'something gone wrong'
    end
  end

  private

  def saml_settings
    idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
    settings = idp_metadata_parser.parse(idp_metadata)
    settings.assertion_consumer_service_url = "" # call back url
    settings.issuer = "" # issuer
    settings.name_identifier_format = "" # format identifier
    settings
  end

  def idp_metadata
    # metadata
  end
end
