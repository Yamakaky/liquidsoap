# Create a reference, i.e. a value that can be modified. This is an alias to @ref@.
# @category Liquidsoap 
def ref.make(x) =
  ref x
end

# Obtain the value stored in a reference. This is an alias to @!@.
# @category Liquidsoap
def ref.get(r) =
  !r
end

# Change the value stored in a reference. This is an alias to @:=@.
# @category Liquidsoap
def ref.set(r, x) =
  r := x
end
