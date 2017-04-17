# frozen_string_literal: true

# Edge Tree Controllers provide a standard interface for accessing resources
# present in the edge tree.
#
# Since this controller includes `NestedResourceHelper`, subclassed models
# are assumed to have `Edgeable` included.
class EdgeTreeController < ServiceController
  include NestedResourceHelper
end
