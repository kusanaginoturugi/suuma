require "bigdecimal"

class VouchersController < ApplicationController
  def new
    @voucher = default_voucher
    @totals = totals(@voucher[:lines])
  end

  def create
    @voucher = build_voucher
    @totals = totals(@voucher[:lines])

    if balanced?(@totals)
      flash.now[:notice] = "振替伝票を受け付けました（まだ保存はしていません）"
      render :new, status: :ok
    else
      flash.now[:alert] = "借方と貸方の合計が一致していません"
      render :new, status: :unprocessable_entity
    end
  end

  private

  def voucher_params
    params.require(:voucher).permit(:recorded_on, :voucher_number, :description, lines: %i[account debit_amount credit_amount note])
  end

  def build_voucher
    lines = voucher_params[:lines]&.map do |line|
      line.to_h.symbolize_keys.slice(:account, :debit_amount, :credit_amount, :note)
    end&.reject { |line| line.values.all?(&:blank?) } || []

    {
      recorded_on: (voucher_params[:recorded_on].presence || Date.current).to_date,
      voucher_number: voucher_params[:voucher_number].presence || default_number,
      description: voucher_params[:description],
      lines: lines.presence || [empty_line]
    }
  end

  def default_voucher
    {
      recorded_on: Date.current,
      voucher_number: default_number,
      description: nil,
      lines: [empty_line, empty_line]
    }
  end

  def empty_line
    { account: "", debit_amount: "", credit_amount: "", note: "" }
  end

  def default_number
    Date.current.strftime("%Y%m%d-001")
  end

  def totals(lines)
    debit = lines.sum { |line| decimal_amount(line[:debit_amount]) }
    credit = lines.sum { |line| decimal_amount(line[:credit_amount]) }
    { debit: debit, credit: credit }
  end

  def balanced?(totals)
    totals[:debit] == totals[:credit]
  end

  def decimal_amount(value)
    BigDecimal(value.to_s.presence || "0")
  end
end
