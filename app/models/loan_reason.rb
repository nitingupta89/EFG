class LoanReason < StaticAssociation
  self.data = [
    { id: 0 , name: "Replacing existing finance (original)" },
    { id: 1, name: "Buying a business" },
    { id: 2, name: "Buying a business overseas" },
    { id: 3, name: "Developing a project" },
    { id: 4, name: "Expanding an existing business" },
    { id: 5, name: "Expanding a UK business abroad" },
    { id: 6, name: "Export" },
    { id: 7, name: "Improving vessels (health and safety)" },
    { id: 8, name: "Increasing size and power of vessels" },
    { id: 9, name: "Improving vessels (refrigeration)" },
    { id: 10, name: "Improving efficiency" },
    { id: 11, name: "Agricultural holdings investments" },
    { id: 12, name: "Boat modernisation (over 5 years)" },
    { id: 13, name: "Production, processing and marketing" },
    { id: 14, name: "Property purchase/lease" },
    { id: 15, name: "Agricultural holdings purchase" },
    { id: 16, name: "Animal purchase" },
    { id: 17, name: "Equipment purchase" },
    { id: 18, name: "Purchasing fishing gear" },
    { id: 19, name: "Purchasing fishing licences" },
    { id: 20, name: "Purchasing fishing quotas" },
    { id: 21, name: "Purchasing fishing rights" },
    { id: 22, name: "Land purchase" },
    { id: 23, name: "Purchasing quotas" },
    { id: 24, name: "Vessel purchase" },
    { id: 25, name: "Research and development" },
    { id: 26, name: "Starting-up trading" },
    { id: 27, name: "Working capital" },
    { id: 28, name: 'Start-up costs' },
    { id: 29, name: 'General working capital requirements' },
    { id: 30, name: 'Purchasing specific equipment or machinery' },
    { id: 31, name: 'Purchasing licences, quotas or other entitlements to trade' },
    { id: 32, name: 'Research and Development activities' },
    { id: 33, name: 'Acquiring another business within UK' },
    { id: 34, name: 'Acquiring another business outside UK' },
    { id: 35, name: 'Expanding an existing business within UK' },
    { id: 36, name: 'Expanding an existing business outside UK' },
    { id: 37, name: 'Replacing existing finance' },
    { id: 38, name: 'Financing an export order' }
  ].sort_by {|data| data[:name] }

  def self.active
    (28..38).collect { |id| find(id) }
  end
end
