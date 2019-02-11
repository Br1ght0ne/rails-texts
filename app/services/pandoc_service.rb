class PandocService
  require 'pandoc-ruby'

  def self.convert(paths, from:, to: :markdown)
    PandocRuby.convert(Array.wrap(paths),
                       from: from.to_sym, to: to.to_sym)
  end
end
