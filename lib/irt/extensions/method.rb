class Method

  def location
    f = l = nil
    n = case
        when arity >= 0
          arity
        when arity == -1
          0
        when arity < -1
          arity.abs - 1
        end
    arr = Array.new(n)
    set_trace_func proc{ |event, file, line, meth_name, binding, classname|
      if name == meth_name
        case event
        when 'call'
          f = file
          l = line
          throw :method_located
       when 'c-call'
          f = "(c-func)"
          throw :method_located
        end
      end
    }
    catch(:method_located) { call *arr }
    [f,l]
  ensure
    set_trace_func nil
  end

  def info
    file, line = location
    { :name  => name,
      :owner => owner.name,
      :file  => file,
      :line  => line,
      :arity => arity }
  end

end
