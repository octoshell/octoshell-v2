class Policy < ApplicationRecord
  has_one_attached :document # для загрузки PDF-документа
end