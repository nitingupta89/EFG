class LoanStatesController < ApplicationController
  def index
    # TODO: Don't do N queries.
    @states = Loan::States.map { |state|
      OpenStruct.new(
        id: state,
        loan_count: current_lender.loans.where(state: state).count,
        name: state.titleize
      )
    }
  end

  def show
    @loans = current_lender.loans.with_state(params[:id]).paginate(per_page: 50, page: params[:page])
  end
end
