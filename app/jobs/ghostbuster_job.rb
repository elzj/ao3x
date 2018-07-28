class GhostbusterJob < ApplicationJob
  queue_as :low_priority

  # In the event that a delete request to elasticsearch has failed,
  # we may have ghost records in the search index that aren't connected
  # to any existing db records. When a search result pulls one of those up,
  # we want to enqueue it to try the delete again.
  def perform(*ghosts)
    # verify that the records can't be found
    # send delete requests to elasticsearch
  end
end
