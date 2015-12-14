require_relative "montana/montana"

get "/" do
  render :example, author: "Chinedu", year: 2016, items: [{name: "Mac", price: 275000000}]
end

get "/new" do
  "I am a Boss"
end

post "/new" do
  [201, {}, req.body]
end

put "/new" do
  [200, {}, ["This is the new PUT endpoint with #{params} params "]]
end