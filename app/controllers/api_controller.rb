class ApiController < ApplicationController  
  def craft
    recipe = find_or_create_recipe
    if recipe.status_active?
      own_discovery = (recipe.result&.discovered_uuid == params[:uuid] || recipe.result&.discovered_by == current_user)
      return render "elements/show", locals: { element: recipe.result, own_discovery: own_discovery }
    end

    if CraftNewElementJob.allow_schedule?(recipe)
      CraftNewElementJob.perform_later(recipe)
      return render "elements/pending"
    end

    return render "elements/pending" if recipe.status_pending?

    render "elements/show", locals: { element: Element.error }
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
