# frozen_string_literal: true

class Text < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  before_validation :ensure_filetype_has_a_value
  before_validation :ensure_no_dot_in_filetype
  before_validation :ensure_file_attached
  after_save :update_attached_file_name
  before_destroy :ensure_admin_or_owner

  def self.acceptable_extensions
    {
      txt: 'Text',
      md: 'Markdown',
      docx: 'Microsoft Word 2010+',
      odt: 'LibreOffice',
      fb2: 'FictionBook 2',
      epub: 'EPUB',
      org: 'Emacs Org-mode',
      rst: 'ReStructured Text',
      asciidoc: 'AsciiDoc',
      tex: 'LaTeX/TeX',
      json: 'JSON'
    }.each_pair
      .map { |ext, name| [ext, "#{name} (.#{ext})"] }
      .to_h
  end

  def self.text_extensions
    [[:txt, 'Text (.txt)'], [:md, 'Markdown (.md)']]
  end

  validates :title, :filetype, presence: true
  validates :title, length: {
    maximum: 255,
    too_long: '%{count} characters is the maximum allowed'
  }
  validates :filetype,
    format: { with: /\w{1,10}/ },
    inclusion: { in: Text.text_extensions.map(&:first).map(&:to_s) }
  # validates :body, length: { maximum: 81_920 }

  def ensure_admin_or_owner
    errors[:base] << 'not allowed to delete'
  end

  def markdown?
    filetype == 'md'
  end

  def filename
    ActiveStorage::Filename.new("#{title.delete('.')}.#{filetype}").sanitized
  end

  def text_to_file!
    Tempfile.open('upload') do |f|
      f.write(body)
      f.rewind
      file.attach(io: f, filename: filename)
    end
  end

  def file_to_text
    path = ActiveStorage::Blob.service.path_for(file.attachment.key)
    PandocService.convert(path, from: filetype)
  end

  def file_to_text!
    self.body = file_to_text
  end

  def ensure_filetype_has_a_value
    self.filetype = 'txt' unless filetype.present?
  end

  def ensure_no_dot_in_filetype
    self.filetype.delete!('.')
  end

  def html_tags
    %w[strong em img b i u p h1 h2 h3 h4 h5 h6 ul ol pre code hr a]
  end

  def html_attributes
    %w[href src]
  end

  def only_file?
    body.blank? && file.attached?
  end

  def only_body?
    body.present? && !file.attached?
  end

  def open_file(&block)
    file.open(&block)
  end

  private

  def ensure_file_attached
    return if file.attached?

    if body.present?
      text_to_file!
    # elsif body.present? && file.attached?
    #   raise NotImplementedError
    #   # file_text = file_to_text
    #   # self.body = "#{body}\n\n---\n\n#{file_text}"
    #   # text_to_file!
    else
      errors.add(:base, "there's no content")
    end
  end

  def update_attached_file_name
    return unless file.attached?

    file.blob.update!(filename: filename)
  end
end
