require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"

before do
  @contents = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |paragraph, num|
      "<p id=\"paragraph#{num+1}\">#{paragraph}</p>"
    end.join
  end
  
  def make_bold(paragraph, query)
    paragraph.gsub(/(#{query})/, '<strong>\1</strong>')
  end
end

not_found do
  redirect "/"
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  
  erb(:home)
end

get "/chapters/:number" do
  number = params[:number].to_i  
  chapter_name = @contents[number - 1]
  
  redirect "/" unless (1..@contents.size).cover?(number)
  
  @title = "Chapter #{number}: #{chapter_name}"
  @chapter = File.read("data/chp#{number}.txt")
  
  erb(:chapter)
end

def get_contents(query)
  chapter_info = []
  @contents.each_with_index do |title, ind|
    text = File.read("data/chp#{ind + 1}.txt")
    if text.include?(query)
      para_info = get_para_info(text, query)
      chapter_info << [title, (ind + 1), para_info]
    end
  end
  
  chapter_info
end

def get_para_info(text, query)
  para_info = []
    if text.include?(query)
      text.split("\n\n").each_with_index do |p, i|
      para_info << [p, (i+1)] if p.include?(query)
    end
  end
  
  para_info
end

get "/search" do
  @query = params[:query]
  @chapter_info = (@query == nil ? [] : get_contents(@query))
  erb(:search)
end