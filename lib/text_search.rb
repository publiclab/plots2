require "lemmatizer"

module TextSearch
  def lemmatize(word)
    lem = Lemmatizer.new
    lem.lemma(word)
  end

  def results_with_probable_hyphens(word)
    lem = Lemmatizer.new("lib/related_and_hyphenated_terms.dict.txt")
    lem.lemma(word)
  end
end
