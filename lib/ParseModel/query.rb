module ParseModel
  class ParseQuery < PFQuery
    
    def setClassObject(classObject)
      @classObject = classObject
      self
    end

    def initWithClassNameAndClassObject(className, classObject:myClassObject)
      @className = className
      self.initWithClassName(className)
      self.setClassObject(myClassObject)
      self
    end

    def find(&block)
      return self.findObjects.map {|obj| @classObject.new(obj)} unless block_given?
       
      self.findObjectsInBackgroundWithBlock(lambda do |objects, error|
        objects = objects.map {|obj| @classObject.new(obj)} if objects
        block.call(objects, error)
      end)
    end

    def getFirst(&block)
      return @classObject.new(self.getFirstObject) unless block_given?

      self.getFirstObjectInBackgroundWithBlock(lambda do |object, error|
        obj = @classObject.new(object) if object
        block.call(obj, error)
      end)
    end

    def get(id, &block)
      return @classObject.new(self.getObjectWithId(id)) unless block_given?

      self.getObjectInBackgroundWithId(id, block:lambda do |object, error|
        obj = @classObject.new(object) if object
        block.call(obj, error)
      end)
    end

    def count(&block)
      return self.countObjects unless block_given?

      self.countObjectsInBackgroundWithBlock(lambda do |count, error|
        block.call(count, error)
      end)
    end

  end

end
