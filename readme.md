##EbokianServer
Built through Test Driven Development, this is an MVC framework to handle database to end-user webservice alongside a set of personal ORM tools inspired by Rails.

##Features
* Generated dynamic Ruby Model Classes from the database.
* Converted SQL queries into arrays of dynamically assigned Ruby Objects.
* Methodized and made chainable the most used SQL database queries.
* Generated dynamic Ruby Controller classes from the RESTful action routes
* Constructed a Router switchboard parse html queries and direct them to the correct controller
* Implemented persistent data storage by creating session cookies

###Deploy Server


###ORM toolset
When you name your model, it must be named as the singular case of the
corresponding table name within your schema. users table matches User model.
Your model must then inherit from SQLObject, and invoke finalize! to register
the tables columns as attributes.
```
class User < SQLObject
  User.finalize!
  ...
end
```
The Model will now have access to the following singleton methods:<br /><br />
*all*<br />
`User.all #=> returns rows in the users table as User objects`
*find(id)*<br />
`User.find(2) #=> returns the row in the users table with an id of 2`
*find_by(col: value)*<br />
```
User.find_by(fname: "Bob") #=> returns user objects whose fname = "Bob"
User.find_by(fname: "Bob", lname: "Smith") #=> returns users who meet both conditions
```
*table_name*<br />
`User.table_name #=> returns the name of the users table`
*columns*<br />
`User.columns #=> returns the headers of each column of the users table`
*where*<br />
This still needs to be setup as chainable, until then it works like find_by
`User.where(...) #=> functions like find_by`
<br /><br />

Instances of the Model will now have access to these basic RESTful methods<br /><br />
*save* <br />
If you instantiate a new User, then set the fname and lname attributes of your
user table and call save, it will INSERT the new row into the database and then
automatically assign it an ID.
```
bob = User.new
bob.fname = "Bob"
bob.lname = "Smith"
bob.save
```
If Bob was already in the database, then calling bob from the database, modify
the objects attributes and calling save will UPDATE those changes into the
corresponding rows within the database
```
bob = User.find_by(fname: "Bob")
bob.lname = "Greenway"
bob.save
```
You can also call `User.insert` or `User.update`.
*destroy* <br />
```
bob = User.find_by(fname: "Bob")
bob.destroy
```

##**ToDo List**
* [ ] Add and test HasManyThrough
* [ ] Add file from which to read and change database constants
* [ ] Build small sample site to showcase the code in action
* [ ] Add database validations and !bang versions of save and destroy
