# frozen_string_literal: true

class Text < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  before_validation :ensure_filetype_has_a_value
  before_validation :ensure_contents
  before_destroy :ensure_admin_or_owner

  validates :title, :filetype, presence: true
  validates :title, length: {
    maximum: 255,
    too_long: '%{count} characters is the maximum allowed'
  }
  # validates :body, length: { maximum: 81_920 }

  def ensure_admin_or_owner
    errors[:base] << 'not allowed to delete'
  end

  def allowed_to_destroy?(other_user)
    other_user&.admin? || user == other_user
  end

  def renderable?
    %w[txt md].include?(filetype)
  end

  def self.acceptable_extensions
    %w[txt md docx odt fb2 epub org rst asciidoc tex json]
  end

  def filename
    ActiveStorage::Filename.new("#{title.delete('.')}.#{filetype}").sanitized
  end

  def render_to_html!
    self.body = HTTParty.post('https://api.github.com/markdown/raw',
                              headers: {
                                'Content-Type' => 'text/plain',
                                'User-Agent' => Rails.configuration.github_username
                              },
                              body: body).body.html_safe
    self.filetype = 'md'
  end

  def text_to_file!
    self.filetype = 'txt'
    Tempfile.open('upload') do |f|
      file.attach(io: f, filename: filename)
    end
  end

  def file_to_text
    contents = file.download
    Tempfile.open('convert') do |oldfile|
      oldfile.write(contents)
      new_path = File.basename(oldfile.path, '.*')
      system(['pandoc', oldfile.path, '-t commonmark', '-o', new_path].join(' '))
      File.open(new_path) do |newfile|
        file.attach(io: newfile, filename: filename)
        return newfile.read
      end
    end
  end

  def file_to_text!
    self.body = file_to_text
  end

  def only_file?
    body.blank? && file.attached?
  end

  def only_body?
    body.present? && !file.attached?
  end

  private

  def ensure_contents
    if only_file?
      file_to_text!
    elsif only_body?
      text_to_file!
    elsif body.present? && file.attached?
      file_text = file_to_text
      self.body = "#{body}\n\n---\n\n#{file_text}"
      text_to_file!
    else
      errors.add(:base, "there's no content")
    end
  end

  def ensure_filetype_has_a_value
    self.filetype = 'txt' unless filetype.present?
  end

  def html_tags
    %w[strong em img b i u p h1 h2 h3 h4 h5 h6 ul ol pre code hr a]
  end

  def html_attributes
    %w[href src]
  end
end
