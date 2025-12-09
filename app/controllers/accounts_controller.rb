class AccountsController < ApplicationController
  before_action :load_accounts, only: %i[index new edit]
  before_action :set_account, only: %i[edit update]

  def index
  end

  def new
    @account = Account.new
  end

  def create
    @account = Account.new(account_params)
    if @account.save
      redirect_to accounts_path, notice: t("accounts.flash.created")
    else
      load_accounts
      flash.now[:alert] = @account.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @account.update(account_params)
      redirect_to accounts_path, notice: t("accounts.flash.updated")
    else
      load_accounts
      flash.now[:alert] = @account.errors.full_messages.join(" / ")
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_account
    @account = Account.find(params[:id])
  end

  def load_accounts
    @accounts = Account.order(:category, :code)
  end

  def account_params
    params.require(:account).permit(:code, :name, :category, :parent_code)
  end
end
