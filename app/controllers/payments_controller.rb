class PaymentsController < ApplicationController
  before_action :set_payment, only: [:edit, :update, :destroy]
  before_action :set_member, only: [:new, :edit, :create, :update]

  # GET /payments
  def index
    @filterrific = initialize_filterrific(
      Payment,
      params[:filterrific],
      :select_options => {
        sorted_by: Payment.options_for_sorted_by,
        by_dues: Payment.options_for_dues_select
      }) or return
    @payments = @filterrific.find.page(params[:page])
    @payments_for_csv = @filterrific.find

    respond_to do |format|
      format.html
      format.js
      format.csv {render text: @payments_for_csv.to_csv}
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  # GET members/:member_id/payments/new
  def new
    @payment = Payment.new
  end

  # GET members/:member_id/payments/1/edit
  def edit
  end

  # POST members/:member_id/payments
  def create
    @payment = Payment.new(payment_params)
    @payment.member_id = @member.id
    if @payment.save
      redirect_to member_path(@member), notice: 'Payment was successfully created.'
    else
      render new_member_payment_path
    end
  end

  # PATCH/PUT members/:member_id/payments/1
  def update
    if @payment.update(payment_params)
      redirect_to payments_path, notice: 'Payment was successfully updated.'
    else
      render edit_member_payment_path
    end
  end

  # DELETE members/:member_id/payments/1
  def destroy
    @payment.destroy
    redirect_to payments_url, notice: 'Payment was successfully destroyed.'
  end

  def import_new
    response = Payment.import_new(params[:file])
    if response.empty?
      redirect_to payments_path, notice: "All rows imported and created."
    else 
      redirect_to payments_path, alert: "#{response.length} rows rejected: #{response.join(", ")}"
    end  
  rescue Exception => e
      redirect_to payments_path, alert: e 
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    def set_member
      @member = Member.find(params[:member_id])
    end
    # Only allow a trusted parameter "white list" through.
    def payment_params
      params.require(:payment).permit(:date, :amount, :dues, :note)
    end
end
