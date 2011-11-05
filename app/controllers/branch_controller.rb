class BranchController < ApplicationController
  def view
    @branch = Branch.find_by_name(params[:name])
  end
end
