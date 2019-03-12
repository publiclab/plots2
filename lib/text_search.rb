require "lemmatizer"

module TextSearch
  def lemmatize(word)
    lem = Lemmatizer.new
    lem.lemma(word)
  end
<<<<<<< HEAD
=======

  def results_with_probable_hyphens(word)
    lem = Lemmatizer.new("lib/related_and_hyphenated_terms.dict.txt")
    lem.lemma(word)
  end
>>>>>>> 1d213449731fbeb492564538213d2938ff7dd7da
end
