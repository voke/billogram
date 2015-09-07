module Billogram
  class Customer < Resource
    attr_accessor :customer_no, :name, :notes, :org_no, :vat_no, :created_at,
      :updated_at, :company_type

    alias_method :id, :customer_no

    relation :address, :one
    relation :contact, :one
    relation :delivery_address, :one, class_override: "Address"

  end
end
