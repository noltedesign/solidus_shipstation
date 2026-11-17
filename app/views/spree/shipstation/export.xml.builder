# frozen_string_literal: true

xml.instruct!
xml.Orders(pages: (@shipments.total_count / 50.0).ceil) do
  @shipments.each do |shipment|
    order = shipment.order

    xml.Order do
      xml.OrderID        { xml.cdata!(shipment.id.to_s[0,50]) }
      xml.OrderNumber    { xml.cdata!(shipment.number.to_s[0,50]) }
      xml.OrderDate      order.completed_at.strftime(SolidusShipstation::ExportHelper::DATE_FORMAT)
      xml.OrderStatus    { xml.cdata!(shipment.state.to_s[0,50]) }
      xml.LastModified   [order.completed_at, shipment.updated_at].max.strftime(SolidusShipstation::ExportHelper::DATE_FORMAT)
      xml.ShippingMethod { xml.cdata!(shipment.shipping_method.try(:name).to_s[0,100]) }
      xml.PaymentMethod  { xml.cdata!(order.payments.last&.payment_method&.name.to_s[0,50]) }
      xml.CurrencyCode   order.currency
      xml.OrderTotal     order.total
      xml.TaxAmount      order.tax_total
      xml.ShippingAmount order.ship_total
      xml.CustomerNotes  { xml.cdata!(order.special_instructions.to_s[0,1000]) }
      xml.InternalNotes  { xml.cdata!(order.try(:internal_note).to_s[0,1000]) }
      xml.Gift           order.try(:gift?) ? 'true' : 'false'
      xml.GiftMessage    { xml.cdata!(order.try(:gift_message).to_s[0,1000]) }
      xml.CustomField1   { xml.cdata!(order.number.to_s[0,100]) }
      xml.CustomField2   { xml.cdata!("") }
      xml.CustomField3   { xml.cdata!("") }

      xml.Customer do
        xml.CustomerCode { xml.cdata!(order.email.to_s[0,50]) }
        SolidusShipstation::ExportHelper.address(xml, order, :bill)
        SolidusShipstation::ExportHelper.address(xml, order, :ship)
      end

      xml.Items do
        shipment.line_items.each do |line|
          variant = line.variant
          xml.Item do
            xml.SKU         { xml.cdata!(variant.sku.to_s[0,100]) }
            xml.Name        { xml.cdata!(strip_tags([variant.product.name, variant.options_text].join(' '))[0,200]) }
            xml.ImageUrl    { xml.cdata!(variant.images.first.try(:attachment).try(:url).to_s[0,200]) }
            xml.Weight      variant.weight.to_f
            xml.WeightUnits SolidusShipstation.configuration.weight_units
            xml.Quantity    line.quantity
            xml.UnitPrice   line.price
            xml.UPC         { xml.cdata!(variant.try(:upc).to_s[0,50]) }
            xml.Location    { xml.cdata!(variant.try(:location).to_s[0,100]) }
            if variant.option_values.present?
              xml.Options do
                variant.option_values.each do |value|
                  xml.Option do
                    xml.Name  { xml.cdata!(value.option_type.presentation.to_s[0,50]) }
                    xml.Value { xml.cdata!(value.name.to_s[0,50]) }
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
