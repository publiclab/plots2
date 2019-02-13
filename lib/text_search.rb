require "lemmatizer"

module TextSearch
  def lemmatize(word)
    lem = Lemmatizer.new
    lem.lemma(word)
  end
end
