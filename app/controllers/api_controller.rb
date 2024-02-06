class ApiController < ApplicationController
  CRAFT_FAILURE_RETRY = 10.minutes
  
  def craft
    recipe = find_or_create_recipe
    return render "elements/show", locals: { element: recipe.result } if recipe.status_active?
    if recipe.status_failed?
      return render "elements/error" unless (Time.current - recipe.updated_at) > CRAFT_FAILURE_RETRY
      recipe.update(status: :scheduled)
    end
    
    CraftNewElementJob.perform_later(recipe) if recipe.status_scheduled?

    render "elements/pending"
  end

  private

  def find_or_create_recipe
    recipe = Recipe.craft(params[:left], params[:right])
    return recipe.first if recipe.any?

    left_element = Element.find_by_name(params[:left])
    right_element = Element.find_by_name(params[:right])

    Recipe.create!(
      left_element: left_element, right_element: right_element, status: :scheduled,
      discovered_by: current_user, discovered_uuid: params[:uuid]
    )
  end
end
