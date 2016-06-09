module I18n
  class I18nRaiseExceptionHandler < ExceptionHandler
    def call(exception, locale, key, options)
      if exception.is_a?(MissingTranslation)
        raise exception.to_exception
      else
        super
      end
    end
  end
end
 
I18n.exception_handler = I18n::I18nRaiseExceptionHandler.new