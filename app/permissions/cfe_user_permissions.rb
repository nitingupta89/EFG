module CfeUserPermissions
  def can_create?(resource)
    [
      Invoice,
      LoanRemoveGuarantee,
      RealisationStatement,
      LoanReport,
      LoanAuditReport,
      SupportRequest
    ].include?(resource)
  end

  def can_update?(resource)
    false
  end

  def can_view?(resource)
    [
      Invoice,
      Loan,
      LoanAlerts,
      LoanChange,
      LoanRemoveGuarantee,
      LoanStates,
      RealisationStatement,
      Search
    ].include?(resource)
  end
end
