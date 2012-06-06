if AppConfig.is_shapadocom
  PaymentsConfig = YAML.load_file("#{Rails.root}/config/payments.yml")[Rails.env]

  if AceVersion.count == 0
    AceVersion.reload!
  end
end
