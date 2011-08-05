module IRT
  module Helpers
    module Rails

      def post(*args)
        data = args.pop
        app.post path(*args), data
      end

      def get(*args)
        app.get path(*args)
      end

      def delete(*args)
        app.delete path(*args)
      end

      def path(*args)
        path = args.shift
        app.send("#{path}_path", *args)
      end

      def response
        app.response.body
      end



    end
  end
end
