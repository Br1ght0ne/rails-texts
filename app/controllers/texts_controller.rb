# frozen_string_literal: true

class TextsController < ApplicationController
  before_action :set_text, only: %i[show edit update destroy]
  before_action :set_extensions, only: %i[show new edit update destroy]
  before_action :authenticate_user!, only: %i[new create update edit destroy]
  before_action :authorize_user!, only: %i[edit update destroy]

  # GET /texts
  # GET /texts.json
  def index
    @texts = Text.by_creation_date.page(params[:page])
  end

  def tags
    @tags = Text.tag_counts.pluck(:name, :taggings_count)
  end

  def tagged
    @tags = Text.tag_counts.pluck(:name, :taggings_count)
    @tag = params[:tag]
    @texts = Text.tagged_with(@tag)
                 .by_creation_date
                 .page(params[:page])
    render 'tags'
  end

  # GET /texts/1
  # GET /texts/1.json
  def show
    return unless @text.body.present?

    @body = MarkdownService.to_html(@text.body)
  end

  # GET /texts/new
  def new
    @text = Text.new
    @type = params[:type]
  end

  # GET /texts/1/edit
  def edit; end

  # POST /texts
  # POST /texts.json
  def create
    @text = current_user.texts.new(text_params.merge(tag_list: tag_list))

    file = params.dig(:text, :file)
    if file
      extname = File.extname(file.original_filename)
      @text.filetype = extname unless extname.blank?
      # @text.file.attach(io: file, filename: @text.filename)
    end

    # @text.ensure_filetype_has_a_value

    respond_to do |format|
      if @text.save
        format.html { redirect_to text_path(@text), notice: 'Text was successfully created.' }
        format.json { render :show, status: :created, location: @text }
      else
        format.html { render :new }
        format.json { render json: @text.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /texts/1
  # PATCH/PUT /texts/1.json
  def update
    respond_to do |format|
      if @text.update(text_params.merge(tag_list: tag_list))
        format.html { redirect_to @text, notice: 'Text was successfully updated.' }
        format.json { render :show, status: :ok, location: @text }
      else
        format.html { render :edit }
        format.json { render json: @text.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /texts/1
  # DELETE /texts/1.json
  def destroy
    @text.destroy
    respond_to do |format|
      format.html { redirect_to texts_url, notice: 'Text was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_text
    @text = Text.find(params[:id])
  rescue StandardError
    redirect_to root_path,
                flash: { error: "Couldn't find text with ID #{params[:id]}." }
  end

  def set_extensions
    @extensions = Text::ACCEPTABLE_EXTENSIONS
                  .each_pair
                  .map { |k, v| [k, v] }
    @text_extensions = Text::TEXT_EXTENSIONS
  end

  def tag_list
    @tag_list ||= text_params[:tag_list].split(/[,\s]+/).join(', ')
  end

  def authorize_user!
    authorize @text
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def text_params
    permitted = %i[title body file page filetype tag_list]
    params.require(:text).permit(permitted)
  end
end
