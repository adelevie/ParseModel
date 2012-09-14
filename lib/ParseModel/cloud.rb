
# with block:
# ParseModel::Cloud.callFunction("myFunction", {"myParam" => "myValue"}) do |result, error|
#  # do something...
# end

# without block:
# ParseModel::Cloud.callFunction("myFunction", {"myParam" => "myValue"})
module ParseModel
  class Cloud
    def self.callFunction(function, params, &block)
      return PFCloud.callFunction(function, withParameters:params) unless block_given?

      PFCloud.callFunctionInBackground(function, withParameters:params, block:lambda do |result, error|
        block.call(result, error)
      end)
    end
  end
end