if AppConfig.is_acecom
  PaymentsConfig = YAML.load_file("#{Rails.root}/config/payments.yml")[Rails.env]

  if QnaVersion.count == 0
    QnaVersion.reload!
  end
end
