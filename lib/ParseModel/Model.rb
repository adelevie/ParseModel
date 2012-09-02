module ParseModel

  module Model
    attr_accessor :PFObject
    
    def initialize(pf_object=nil)
      if pf_object
        @PFObject = pf_object
      else
        @PFObject = PFObject.objectWithClassName(self.class.to_s)
      end
    end
    
    def method_missing(method, *args, &block)
      if fields.include?(method)
        @PFObject.objectForKey(method)
      elsif fields.map {|f| "#{f}="}.include?("#{method}")
        method = method.split("=")[0]
        @PFObject.setObject(args.first, forKey:method)
      elsif @PFObject.respond_to?(method)
        @PFObject.send(method, *args, &block)
      else
        super
      end
    end
        
    def fields
      self.class.send(:get_fields)
    end
  
    module ClassMethods
      def fields(*args)
        args.each {|arg| field(arg)}
      end
    
      def field(name)
        @fields ||= []
        @fields << name
      end

      def query
        ParseModel::Query.alloc.initWithClassNameAndClassObject(self.name, classObject:self)
      end
      
      def get_fields
        @fields
      end
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end