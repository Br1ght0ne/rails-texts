# frozen_string_literal: true

class AddFiletypeToTexts < ActiveRecord::Migration[5.2]
  def change
    add_column :texts, :filetype, :string
  end
end
