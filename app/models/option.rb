class Option

  include Mongoid::Document

  field :name, type: String
  field :value, type: String

  attr_accessor :value_EMAIL_SERVICE
end