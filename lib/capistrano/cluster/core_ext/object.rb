class Object
  def copy
    copy = dup
    copy.make_independent!
    copy
  end

  def make_independent!
    instance_variables.each do |var|
      value = instance_variable_get(var)

      if (value.respond_to?(:dup))
        instance_variable_set(var, value.dup)
      end
    end
  end
end
