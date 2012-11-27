class DocController < ApplicationController
  layout :set_layout

  def privacy
    set_page_title("Privacy")
  end
  def tos
    set_page_title("Terms of service")
  end

  def plans
    set_page_title(t('doc.plans.title'))
  end

  def chat
    set_page_title(t('doc.chat.title'))
  end

  def faq
    set_page_title("Frequently Asked Questions")
  end
end
