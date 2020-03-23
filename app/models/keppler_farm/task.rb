class KepplerFarm::Task < ApplicationRecord
  belongs_to :farm, class_name: 'KepplerFarm::Farm'
  belongs_to :user, optional: true

  validates_presence_of :title, :text

  def colors
    [
      ['Azul oscuro', 'aecbfa'],
      ['Azul claro', 'cbf0f8'],
      %w[Amarillo fbbc04],
      %w[Morado d7aefb],
      %w[Verde ccff90],
      %w[Rojo f28b82],
      %w[Gris e8eaed]
    ]
  end
end
