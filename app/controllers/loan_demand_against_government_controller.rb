class LoanDemandAgainstGovernmentController < ApplicationController
  def new
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_against_government = LoanDemandAgainstGovernment.new(@loan)
    enforce_create_permission(@loan_demand_against_government)
    @loan_demand_against_government.dti_demanded_on = Date.today
  end

  def create
    @loan = current_lender.loans.find(params[:loan_id])
    @loan_demand_against_government = LoanDemandAgainstGovernment.new(@loan)
    enforce_create_permission(@loan_demand_against_government)
    @loan_demand_against_government.attributes = params[:loan_demand_against_government]
    @loan_demand_against_government.dti_demanded_on = Date.today

    if @loan_demand_against_government.save
      redirect_to loan_url(@loan)
    else
      render :new
    end
  end
end
