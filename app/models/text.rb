# frozen_string_literal: true

class Text < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  before_validation :ensure_filetype_has_a_value
  before_validation :ensure_file_attached
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

  def markdown?
    filetype == 'md'
  end

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

  def ensure_filetype_has_a_value
    self.filetype = 'txt' unless filetype.present?
  end

  def html_tags
    %w[strong em img b i u p h1 h2 h3 h4 h5 h6 ul ol pre code hr a]
  end

  def html_attributes
    %w[href src]
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
end
