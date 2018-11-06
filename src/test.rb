

dict = {}

dict['Regex'] = %r"\/[a-zA-Z1-9\-\/_]*[\.]?[a-z]*"
dict['String'] = "/whatever.html"

puts Regexp == dict['Regex'].class
puts String == dict['String'].class

matcher = "/index.html"

if dict['Regex'] =~ matcher
  puts "True"
  puts matcher =~ dict['Regex']
else
  puts "False"
end
