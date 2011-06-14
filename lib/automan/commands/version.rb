module Automan::Command
  class Version < Base
    def index
      display Automan.version
    end
  end
end
