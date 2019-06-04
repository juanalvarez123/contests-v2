class User

  include Mongoid::Document
  include Mongoid::Timestamps

  field :first_name, type: String
  field :last_name, type: String
  field :email, type: String
  field :password, type: String

  validates :first_name, presence: { message: "Los nombres son obligatorios" }
  validates :last_name, presence: { message: "Los apellidos son obligatorios" }
  validates :email, presence: { message: "El correo electrónico es obligatorio" }
  validates :email, uniqueness: { message: "El correo electrónico ya está en uso" }
  validates :password,
            confirmation: { message: "Las contraseñas no coinciden" },
            presence: { message: "La contraseña es obligatoria" }
  validates :password_confirmation, presence: { message: "La confirmación de la contraseña es obligatoria" }
end
