module ParseModel
	class Query < PFQuery
		
		def setClassObject(classObject)
      @classObject = classObject
    end

    def initWithClassNameAndClassObject(className, classObject:myClassObject)
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
	end

end