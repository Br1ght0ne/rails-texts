# frozen_string_literal: true

json.extract! text, :id, :title, :body, :user_id, :created_at, :updated_at
json.url text_url(text, format: :json)
