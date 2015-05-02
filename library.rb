#PPL coursework Ruby by Zsolt Balvanyos, username zbalva01.
require 'singleton'
require 'set'

class Calendar
  include Singleton

  attr_accessor :current_date

  def initialize
    @current_date = 0
  end

  def get_date
    return current_date
  end

  def advance
    @current_date += 1
  end
end
#-----------------------------------------------------------------
class Book
  attr_accessor :id, :title, :author, :due_date

  def initialize(id, title, author)
    @id = id
    @title = title
    @author = author
    @due_date = nil
  end

  def get_id
    return id
  end

  def get_title
    return title
  end

  def get_author
    return author
  end

  def get_due_date
    return due_date
  end

  def check_out(due_date)
    @due_date = due_date
  end

  def check_in
    @due_date = nil
  end

  def to_s
    return "#{@id}: #{@title}, by #{@author}"
  end

end
#-----------------------------------------------------------------
class Member
  attr_accessor :name, :library, :book_out

  def initialize(name, library)
    @name = name
    @library = library
    @book_out = Set.new
  end

  def check_out(book)
    if @book_out.size < 4
      @book_out << book
    end
  end

  def give_back(book)
    @book_out.reject!{|x| x == book}
  end

  def get_books
    return @book_out
  end

  def set_overdue_notice(notice)
    puts @name + notice
  end

  def print_books
    @book_out.each{|x| puts x}
  end
end
#-----------------------------------------------------------------
class Library
  include Singleton
  attr_accessor :all_books

  def initialize
    @all_books = Set.new
    @out_books = Set.new
    @text = []
    @counter = 0
    f = File.open("collection.txt")
    f.each_with_index{ |line, i| make_book(i, line) }

    @cal = Calendar.instance
    @members = Hash.new
    @open = false
    @currently_served = nil
  end

  def open
    if(@open)
      raise 'The library is already open!'
    end
    @cal.advance
    @open = true
    return "Today is day #{@cal.get_date}"
  end

  def find_all_overdue_books
    @members.each do |i|
      puts '==========================================='
      puts i.name
      i_od_book = get_overdue_books(i.get_books)
      if(i_od_book.empty?)
        puts 'No books are overdue'
      else
        i_od_book.each{|b| puts b.title + ' by ' + b.author}
      end
    end
  end

  def get_overdue_books(books)
    result = []
    books.each{|x| result << x if x.due_date < @cal.get_date}
  end

  def issue_card(name_of_member)
    if(!@open)
      raise 'The library is not open.'
    end
    if @members.has_key?(name_of_member)
      return name_of_member + 'already has a library card.'
    else
      @members[:name_of_member] = Member.new(name_of_member, self)
      return 'Library card issued to ' + name_of_member + '.'
    end
  end

  def make_book(id, book_data)
    data = book_data.split(',',2)
    @all_books << Book.new(id,data[0], data[1])
  end

  def serve(name_of_member)
    if(!@open)
      raise 'The library is not open.'
    end
    if(!@members.has_key?(name_of_member))
      return "#{name_of_member}	does	not	have	a	library	card."
    else
      @currently_served = @members[name_of_member]
      return "Now	serving #{name_of_member}."
    end
  end

  def find_overdue_books
    if(!@open)
      raise 'The library is not open.'
    end
    if(@currently_served == nil)
      raise "No	member	is	currently	being	served."
    end
    books = @currently_served.get_books
    od_books = []
    books.each { |b| od_books << b if b.get_due_date < @cal.get_date}
    if(od_books.empty?)
      puts 'None'
    else
      od_books.each{|b| puts b.to_s }
    end
  end

  def check_in(id, *more_id)
    books_back = []
    ids = []
    ids << id
    ids << more_id
    ids.each do [i]
      @out_books.each{|b| books_back << b if b.get_id == i }
    end
  end

  def search(string)
    if (string.size < 4)
      puts "Search string must contain at least four characters."
    else
      findings = []
      @all_books.each { |b| findings << b if ((b.title.to_s.downcase.match(string.to_s.downcase)).to_s == string.to_s)}
      if(findings.empty?)
        puts "No books found."
      else
        findings.each { |f| puts f}
      end
    end
  end

  def check_out(id, *more_id)
    if(!@open)
      raise 'The library is not open.'
    end
    if(@currently_served == nil)
      raise "No	member	is	currently	being	served."
    end
    ids = []
    ids << get_book(id)
    more_id.each{ |i| ids << get_book(i)}

    ids.each { |book| raise "The member does not have book #{book.id}" unless @currently_served.book_out.member(book)}
    ids.each { |book| @all_books >> book}
    ids.each { |book| @out_books <<  book}
  end

  def renew(id, *more_id)
    if(!@open)
      raise 'The library is not open.'
    end
    if(@currently_served == nil)
      raise "No	member	is	currently	being	served."
    end
    ids = []
    ids << get_book(id)
    more_id.each{ |i| ids << get_book(i)}

    ids.each { |book| raise "The member does not have book #{book.id}" unless @currently_served.book_out.member(book)}
    ids.each { |book| book.due_date += 7}
  end

  def close
    if(!@open)
      raise 'The library is not open.'
    end
    @open = false
    puts 'Good night.'
  end

  def quit
    puts 'The library is now closed for renovation.'
  end

  def get_book(id)
    @all_books.each{|book| return book if book.id == id}
  end

  def add_book(book)
    @all_books << book
  end

  def get_books
    puts @all_books.empty?
    @all_books.each { |b| puts "#{b.get_title} by #{b.get_author}" }
  end
end
