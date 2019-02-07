# frozen_string_literal: true

json.array! @texts, partial: 'texts/text', as: :text
