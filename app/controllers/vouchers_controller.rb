class VouchersController < ApplicationController
  def index
    @vouchers = Voucher.includes(:voucher_lines).order(recorded_on: :desc, created_at: :desc)
  end

  def new
    @voucher = Voucher.new(recorded_on: Date.current, voucher_number: default_number)
    2.times { @voucher.voucher_lines.build }
    load_accounts
  end

  def create
    @voucher = Voucher.new(voucher_params)
    load_accounts

    if @voucher.save
      redirect_to vouchers_path, notice: t("vouchers.flash.saved")
    else
      @voucher.voucher_lines.build if @voucher.voucher_lines.empty?
      flash.now[:alert] = @voucher.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def voucher_params
    params.require(:voucher).permit(:recorded_on, :voucher_number, :description,
      voucher_lines_attributes: %i[id account_code account debit_amount credit_amount note _destroy])
  end

  def default_number
    Date.current.strftime("%Y%m%d-001")
  end

  def load_accounts
    @accounts = Account.order(:code)
  end
end
