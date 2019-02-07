# frozen_string_literal: true

class CreateTexts < ActiveRecord::Migration[5.2]
  def change
    create_table :texts do |t|
      t.string :title
      t.text :body
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
