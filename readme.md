##EbokianServer
Built through Test Driven Development, this is an MVC framework to handle database to end-user webservice alongside a set of personal ORM tools inspired by Rails.

##Features
* Generated dynamic Ruby Model Classes from the database.
* Converted SQL queries into arrays of dynamically assigned Ruby Objects.
* Methodized and made chainable the most used SQL database queries.
* Generated dynamic Ruby Controller classes from the RESTful action routes
* Constructed a Router switchboard parse html queries and direct them to the correct controller
* Implemented persistent data storage by creating session cookies

###Code Snippets

When initializing a new instance of an SQL object the SQL database response is collected and passed into the method as a hash. The hash is then iterated over and if the params are valid, it invokes the the method, stores the key in an attributes hash and assigns the value to the object.
```
# Dynamically create setter/getter methods for columns attributes
def self.finalize!
  columns.each do |column|
    define_method(column) do
      attributes[column]
    end

    define_method("#{column}=") do |value|
      attributes[column] = value
    end
  end
end
```
Here is an example using the SQL to Ruby ORM tools. The database is called through DBConnection, the SQL query runs, and the results are parsed into an array with each object invoking its own model object.
```
# Query the table and collect all entries
def self.all
  results = DBConnection.execute(<<-SQL)
  SELECT *
  FROM #{table_name}
  SQL
  parse_all(results)
end

# Invokes a query element returns a ruby array of SQL objects
def self.parse_all(results)
  results.map { |result| self.new(result) }
end
```
One of the more complicated methods implemented are the associations. Here, when belongs_to is called it first creates another storage object that sets any missing parameters to default values, and stores the response into a hash to invoke in has_one_through calls.

The code then dynamically builds the method using the method's declared name, the two keys required to make the joins table SQL invocation, and the klass of the modal to which this object is joining to. Finally the SQL query is invoked and the parsed SQL object is return from this method.
```
def belongs_to(name, options = {})
  options = BelongsToOptions.new(name, options)
  self.assoc_options[name] = options

  define_method(name) do
    klass = options.send :model_class
    f_key = options.send :foreign_key
    p_key = options.send :primary_key
    object = klass.where(p_key => send(f_key)).first
  end
end
```

##**ToDo List**
* [ ] Add and test HasManyThrough
* [ ] Add file from which to read and change database constants
* [ ] Build small sample site to showcase the code in action 
