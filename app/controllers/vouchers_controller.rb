class VouchersController < ApplicationController
  before_action :set_voucher, only: %i[edit update destroy]

  def index
    @accounts = Account.order(:code)
    @accounts_map = @accounts.pluck(:code, :name).to_h
    @account_code = resolve_account_filter
    @description_filter = resolve_description_filter
    @account_codes = expand_account_codes(@account_code)
    scope = Voucher.includes(:voucher_lines).order(recorded_on: :asc, created_at: :asc)
    if @account_codes.present?
      scope = scope.joins(:voucher_lines).where(voucher_lines: { account_code: @account_codes }).distinct
    end
    if @description_filter.present?
      scope = scope.where("description LIKE ?", "%#{@description_filter}%")
    end
    @vouchers = scope
    line_scope = VoucherLine.where(voucher_id: @vouchers.select(:id))
    if @account_codes.present?
      line_scope = line_scope.where(account_code: @account_codes)
    end
    @total_debit = line_scope.sum(:debit_amount)
    @total_credit = line_scope.sum(:credit_amount)
  end

  def new
    @voucher = Voucher.new(recorded_on: Date.current)
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

  def quick
    load_accounts
    prepare_quick_view
    defaults = quick_defaults
    @form = QuickVoucherForm.new(defaults.merge(recorded_on: defaults[:recorded_on] || Date.current))
  end

  def create_quick
    @form = QuickVoucherForm.new(**quick_params)
    load_accounts

    if @form.save
      store_quick_defaults
      redirect_to quick_vouchers_path, notice: t("vouchers.flash.saved")
    else
      prepare_quick_view
      flash.now[:alert] = @form.errors.full_messages.join(" / ")
      render :quick, status: :unprocessable_entity
    end
  end

  private

  def set_voucher
    @voucher = Voucher.includes(:voucher_lines).find(params[:id])
  end

  def voucher_params
    params.require(:voucher).permit(:recorded_on, :voucher_number, :description,
      voucher_lines_attributes: %i[id account_code account debit_amount credit_amount note _destroy])
  end

  def load_accounts
    @accounts = Account.order(:code)
  end

  def quick_params
    params.require(:quick_voucher).permit(:recorded_on, :direction,
      :account_code_deposit, :counter_account_code_deposit,
      :account_code_withdrawal, :counter_account_code_withdrawal,
      :amount_deposit, :amount_withdrawal,
      :description_deposit, :description_withdrawal)
  end

  def prepare_quick_view
    @accounts_map = @accounts.index_by(&:code).transform_values(&:name)
    @recent_vouchers = Voucher.includes(:voucher_lines).order(created_at: :desc).limit(20)
  end

  def resolve_account_filter
    if params.key?(:account_code)
      if params[:account_code].present?
        session[:vouchers_account_code] = params[:account_code]
      else
        session.delete(:vouchers_account_code)
      end
      return params[:account_code].presence
    end

    session[:vouchers_account_code].presence
  end

  def resolve_description_filter
    if params.key?(:description)
      if params[:description].present?
        session[:vouchers_description] = params[:description]
      else
        session.delete(:vouchers_description)
      end
      return params[:description].presence
    end

    session[:vouchers_description].presence
  end

  def expand_account_codes(code)
    return nil if code.blank?
    codes = [code]
    queue = [code]
    while queue.any?
      current = queue.shift
      children = Account.where(parent_code: current).pluck(:code)
      queue.concat(children)
      codes.concat(children)
    end
    codes.uniq
  end

  def store_quick_defaults
    session[:quick_voucher_last] = quick_params.slice(
      :recorded_on,
      :account_code_deposit, :counter_account_code_deposit, :description_deposit,
      :account_code_withdrawal, :counter_account_code_withdrawal, :description_withdrawal
    ).to_h
  end

  def quick_defaults
    (session[:quick_voucher_last] || {}).symbolize_keys
  end
end
