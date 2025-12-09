class VouchersController < ApplicationController
  def new
    @voucher = Voucher.new(recorded_on: Date.current, voucher_number: default_number)
    2.times { @voucher.voucher_lines.build }
  end

  def create
    @voucher = Voucher.new(voucher_params)

    if @voucher.save
      redirect_to new_voucher_path, notice: "振替伝票を保存しました"
    else
      @voucher.voucher_lines.build if @voucher.voucher_lines.empty?
      flash.now[:alert] = @voucher.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def voucher_params
    params.require(:voucher).permit(:recorded_on, :voucher_number, :description,
      voucher_lines_attributes: %i[id account debit_amount credit_amount note _destroy])
  end

  def default_number
    Date.current.strftime("%Y%m%d-001")
  end
end
