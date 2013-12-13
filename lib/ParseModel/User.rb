module ParseModel
  module User
    attr_accessor :PFUser

    RESERVED_KEYS = ['username', 'password', 'email']

    def initialize(pf_user_object=nil)
      if pf_user_object
        @PFUser = pf_user_object
      else
        @PFUser = PFUser.user
      end
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
        @fields ||= []
        @fields << name
      end

      def current_user
        if PFUser.currentUser
          u = new
          u.PFUser = PFUser.currentUser
          return u
        else
          return nil
        end
      end

      def query
        PFUser.query
      end

      def all(&block)
        return PFUser.query.findObjects.map {|obj| self.new(obj)} unless block_given?

        PFUser.query.findObjectsInBackgroundWithBlock(lambda do |objects, error|
          objects = objects.map {|obj| self.new(obj)} if objects
          block.call(objects, error)
        end)
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
