class BankImportsController < ApplicationController
  def new
    @form = BankCsvImportForm.new(default_params)
    @accounts = Account.order(:code)
  end

  def create
    @form = BankCsvImportForm.new(import_params)
    @accounts = Account.order(:code)

    if @form.save
      redirect_to vouchers_path, notice: t("bank_imports.flash.imported", count: @form.created_count)
    else
      flash.now[:alert] = @form.errors.full_messages.join(" / ")
      render :new, status: :unprocessable_entity
    end
  end

  private

  def import_params
    params.require(:bank_csv_import_form).permit(
      :file, :bank_account_code, :deposit_counter_code, :withdrawal_counter_code,
      :date_column, :description_column, :deposit_column, :withdrawal_column
    )
  end

  def default_params
    {
      bank_account_code: "102",
      deposit_counter_code: "401",
      withdrawal_counter_code: "520",
      date_column: "日付",
      description_column: "摘要",
      deposit_column: "入金額",
      withdrawal_column: "出金額"
    }
  end
end
