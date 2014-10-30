class NotesController < ApplicationController
  before_action :set_note, only: [:show, :edit, :update]
  before_action :set_member, only: [:new, :edit, :create, :update]  

  # GET /members/:member_id/notes/new
  def new
    @note = Note.new
  end

  # GET /members/:member_id/notes/1/edit
  def edit
    #raise 'x'
  end

  # POST /members/:member_id/notes
  def create
    @note = Note.new(note_params)
    @note.member_id = @member.id
    if @note.save
      redirect_to @member, notice: 'Note was successfully created.'
    else
      render new_member_note_path
    end
  end

  # PATCH/PUT /members/:member_id/notes/1
  def update
    if @note.update(note_params)
      redirect_to @member, notice: 'Note was successfully updated.'
    else
      render edit_member_note_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_note
      @note = Note.find(params[:id])
    end

    def set_member
      @member = Member.find(params[:member_id])
    end    

    # Only allow a trusted parameter "white list" through.
    def note_params
      params.require(:note).permit(:content, :date)
    end
end
