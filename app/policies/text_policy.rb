class TextPolicy < ApplicationPolicy
  %w[edit update destroy].each do |action|
    define_method("#{action}?".to_sym) do
      user&.admin? || record.user == user
    end
  end
end
