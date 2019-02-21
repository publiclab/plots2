require "lemmatizer"

module TextSearch
  def lemmatize(word)
    lem = Lemmatizer.new
    lem.lemma(word)
  end

  def non_hyphenate_query(word)
    word.gsub('-','')
  end

  def results_with_probable_hyphens(word)
  	lem = Lemmatizer.new("lib/hyphenated_words.dict.txt")
  	lem.lemma(word)
  end
end
