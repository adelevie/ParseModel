module Parse
  module User
    attr_accessor :PFUser
    
    RESERVED_KEYS = ['username', 'password', 'email']
    
    def initialize
      @PFUser = PFUser.user
    end
    
    def method_missing(method, *args, &block)
      if RESERVED_KEYS.include?(method)
        @PFUser.send(method)
      elsif RESERVED_KEYS.map {|f| "#{f}="}.include?("#{method}")
        @PFUser.send(method, args.first)
      elsif fields.include?(method)
        @PFUser.objectForKey(method)
      elsif fields.map {|f| "#{f}="}.include?("#{method}")
        method = method.split("=")[0]
        @PFUser.setObject(args.first, forKey:method)
      elsif @PFUser.respond_to?(method)
        @PFUser.send(method, *args, &block)
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
        @fields
      end
      
      def get_fields
        @fields ||= []
        @fields
      end
      
      def all
        query = PFQuery.queryForUser
        users = query.findObjects
        users
      end
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
  end

  module Model
    attr_accessor :PFObject
    
    def initialize
      @PFObject = PFObject.objectWithClassName(self.class.to_s)
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
      
      def get_fields
        @fields
      end
    end
    
    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end