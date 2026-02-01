class VoucherLinesController < ApplicationController
  before_action :set_line

  def update_counterpart
    new_code = params.require(:counter_account_code)
    account = Account.find_by(code: new_code)
    unless account
      redirect_back fallback_location: accounts_path, alert: "科目コード #{new_code} が存在しません" and return
    end

    other_lines = @line.voucher.voucher_lines.where.not(id: @line.id)
    if other_lines.blank?
      redirect_back fallback_location: accounts_path, alert: "相手科目の行がありません" and return
    end

    VoucherLine.transaction do
      other_lines.update_all(account_code: new_code)
    end

    redirect_back fallback_location: accounts_path, notice: "資金移動先を更新しました"
  end

  private

  def set_line
    @line = VoucherLine.find(params[:id])
  end
end
