class Api::V1::CommissionsController < Api::V1::BaseController
  def lookup
    if params['device_id'] == '0fd7259e241237a685369b26e0abb5cbb9e68722'
      render_result polling_place_region: 77, polling_place_id: 123, polling_place_kind: 'uik'
    else
      render_error "Not Implemented"
    end
  end
end