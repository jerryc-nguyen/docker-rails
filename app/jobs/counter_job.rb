class CounterJob < ApplicationJob
  queue_as :default

  def perform(*args)
    p "Log here!!"
    24 + 24
  end
end
