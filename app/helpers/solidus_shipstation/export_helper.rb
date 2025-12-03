# frozen_string_literal: true

require 'builder'

module SolidusShipstation
  module ExportHelper
    DATE_FORMAT = '%m/%d/%Y %H:%M'

    # rubocop:disable all
    def self.address(xml, order, type)
      name = "#{type.to_s.titleize}To"
      address = order.send("#{type}_address")

      xml.__send__(name) do
        xml.Name     { xml.cdata!(address.respond_to?(:name) ? address.name.to_s[0,100] : address.full_name.to_s[0,100]) }
        xml.Company  { xml.cdata!(address.company.to_s[0,100]) }
        xml.Phone    { xml.cdata!(address.phone.to_s[0,50]) }
        xml.Email    { xml.cdata!(order.email.to_s[0,50]) } if type == :bill
        if type == :ship
          xml.Address1   { xml.cdata!(address.address1.to_s[0,100]) }
          xml.Address2   { xml.cdata!(address.address2.to_s[0,100]) }
          xml.City       { xml.cdata!(address.city.to_s[0,100]) }
          xml.State      { xml.cdata!(address.state ? address.state.abbr.to_s[0,50] : address.state_name.to_s[0,50]) }
          xml.PostalCode { xml.cdata!(address.zipcode.to_s[0,20]) }
          xml.Country    { xml.cdata!(address.country.iso.to_s[0,2]) }
        end
      end
    end
    # rubocop:enable all
  end
end
