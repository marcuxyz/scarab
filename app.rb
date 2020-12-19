require 'ostruct'

module StringModule
  class Min
    def validate limit, input
      if input.length < limit
        message = Hash.new
        message[:type] = "string"
        message[:message] = "houve um erro pois #{input} é menor que #{limit}"
        message[:field] = "min"
        return message
      end
      return []
    end
  end

  class Max
    def validate limit, input
    end
  end

  class Required 
    def validate input
    end
  end
end

class Scarab
  MODULES = {
    string: StringModule,
  }

  def initialize()
    @rules = []
    @validations = []
  end

  def method_missing(name, *args)
    @rules << OpenStruct.new(name: name, params: args)
    self
  end

  def object(schema)
    class_instance = nil

    @rules.each do | rule |
      if rule.name == @rules.first.name
        class_instance = MODULES[rule.name]
      else
        schema.keys.each do | field |
          @validations << {
            field: field,
            rule: class_instance.const_get(rule.name.capitalize),
            param: rule.params[0]
          }
        end
      end
    end
    self
  end

  def validate data
    @validations.each do | v |
      p v[:rule].new.validate v[:param], data[v[:field]]
    end
  end
end

scarab = Scarab.new

schema = scarab.object({
  username: scarab.string().min(50).required(),
  email: scarab.string().max(84).is_email().required(),
  age: scarab.integer().min(18).max(25),
  password: scarab.string().min(6).required(),
})

schema.validate({ 
  :name => 'Marcus Pereira',
  :email => 'marcus@example.com',
  :age => 18,
  :password => '123456'
})
