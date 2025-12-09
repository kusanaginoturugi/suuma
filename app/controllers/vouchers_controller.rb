class VouchersController < ApplicationController
  before_action :set_voucher, only: %i[edit update destroy]

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

  def edit
    load_accounts
  end

  def update
    load_accounts
    if @voucher.update(voucher_params)
      redirect_to vouchers_path, notice: t("vouchers.flash.updated", default: "振替伝票を更新しました")
    else
      flash.now[:alert] = @voucher.errors.full_messages.join(" / ")
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @voucher.destroy!
    redirect_to vouchers_path, notice: t("vouchers.flash.deleted", default: "振替伝票を削除しました")
  end

  private

  def set_voucher
    @voucher = Voucher.includes(:voucher_lines).find(params[:id])
  end

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
