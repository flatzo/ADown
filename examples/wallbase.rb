$LOAD_PATH << '../lib'
require 'adown'

album = Wallbase::Album.new(81218)
album.download('/tmp/bob')
