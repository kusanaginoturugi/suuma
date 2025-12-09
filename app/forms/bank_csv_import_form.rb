require "csv"
require "nkf"

class BankCsvImportForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :file
  attribute :bank_account_code, :string
  attribute :deposit_counter_code, :string
  attribute :withdrawal_counter_code, :string
  attribute :date_column, :string, default: "日付"
  attribute :description_column, :string, default: "摘要"
  attribute :deposit_column, :string, default: "入金額"
  attribute :withdrawal_column, :string, default: "出金額"
  attribute :setting_id, :integer
  attribute :setting_name, :string
  attribute :save_setting, :boolean, default: false

  attr_reader :created_count

  validates :file, presence: true
  validates :bank_account_code, :deposit_counter_code, :withdrawal_counter_code, presence: true
  validate :accounts_exist

  def save
    return false unless valid?

    @created_count = 0
    ActiveRecord::Base.transaction do
      persist_setting if save_setting?

      tempfile = file.tempfile
      encoding = detect_encoding(tempfile)
      tempfile.rewind

      CSV.foreach(tempfile, headers: true, encoding: "#{encoding}:UTF-8") do |row|
        amount_in = decimal(row[deposit_column])
        amount_out = decimal(row[withdrawal_column])
        next if amount_in.zero? && amount_out.zero?

        recorded_on = parse_date(row[date_column])
        description = row[description_column].to_s.strip
        if amount_in.positive?
          create_voucher(recorded_on, description, amount_in, :deposit)
        elsif amount_out.positive?
          create_voucher(recorded_on, description, amount_out, :withdrawal)
        end
      end
    end

    errors.add(:base, I18n.t("bank_imports.errors.no_rows")) if created_count.zero?
    errors.empty?
  rescue StandardError => e
    errors.add(:base, e.message)
    false
  end

  private

  def accounts_exist
    %i[bank_account_code deposit_counter_code withdrawal_counter_code].each do |key|
      code = public_send(key)
      errors.add(key, I18n.t("bank_imports.errors.account_missing", code: code)) if code.present? && Account.find_by(code: code).nil?
    end
  end

  def detect_encoding(io)
    io.rewind
    sample = io.read(4000) || ""
    return "UTF-8" if sample.start_with?("\uFEFF")

    guessed = NKF.guess(sample)
    case guessed
    when Encoding::Shift_JIS, Encoding::Windows_31J, Encoding::CP932
      "CP932"
    when Encoding::UTF_8
      "UTF-8"
    else
      "UTF-8"
    end
  ensure
    io.rewind
  end

  def save_setting?
    ActiveModel::Type::Boolean.new.cast(save_setting) || setting_name.present?
  end

  def persist_setting
    setting = if setting_id.present?
                BankImportSetting.find_by(id: setting_id)
              end
    setting ||= BankImportSetting.find_or_initialize_by(name: setting_name.presence || I18n.t("bank_imports.shared.default_setting_name"))

    setting.assign_attributes(
      bank_account_code: bank_account_code,
      deposit_counter_code: deposit_counter_code,
      withdrawal_counter_code: withdrawal_counter_code,
      date_column: date_column,
      description_column: description_column,
      deposit_column: deposit_column,
      withdrawal_column: withdrawal_column
    )
    setting.save!
  end

  def create_voucher(recorded_on, description, amount, direction)
    voucher = Voucher.new(recorded_on: recorded_on, description: description)

    if direction == :deposit
      voucher.voucher_lines.build(account_code: bank_account_code, debit_amount: amount, credit_amount: 0)
      voucher.voucher_lines.build(account_code: deposit_counter_code, debit_amount: 0, credit_amount: amount)
    else
      voucher.voucher_lines.build(account_code: withdrawal_counter_code, debit_amount: amount, credit_amount: 0)
      voucher.voucher_lines.build(account_code: bank_account_code, debit_amount: 0, credit_amount: amount)
    end

    voucher.save!
    @created_count += 1
  end

  def parse_date(value)
    Date.parse(value.to_s)
  rescue ArgumentError
    raise I18n.t("bank_imports.errors.invalid_date", value: value)
  end

  def decimal(value)
    BigDecimal(value.to_s.gsub(/[, ]/, ""))
  rescue ArgumentError, TypeError
    0.to_d
  end
end
