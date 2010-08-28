module IRT
  module Directives

    %w[ core test history system ].each do |mod|
      require "irt/directives/#{mod}"
      eval "extend #{mod.capitalize}"
    end

  end
end
