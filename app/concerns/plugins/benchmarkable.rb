module Plugins
  module Benchmarkable
    def self.included base
      base.key :processing_time, Float
    end
    
    def benchmark seconds
      self.processing_time = seconds
      save
    end
    
    def clear_processing_time!
      self.processing_time = nil
      save
    end
  end
end
