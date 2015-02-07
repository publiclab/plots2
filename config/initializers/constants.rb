module Callouts
  FINDER = /(^|\W)\@([\w-]+)(\W|$)/
  PRETTYLINK = '\1[@\2](/profile/\2)\3'
end
