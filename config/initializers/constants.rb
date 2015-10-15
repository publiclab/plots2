module Callouts
  FINDER = /(^|\W)\@([\w-]+)/
  PRETTYLINKMD = '\1[@\2](/profile/\2)'
  PRETTYLINKHTML = '\1<a href="/profile/\2">@\2</a>'
end
