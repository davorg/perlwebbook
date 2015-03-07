# Underlying Tools

All of the web development mechanisms that we will cover use many of
the same underlying tools. To avoid repetition, we will introduce some
of the most important of these tools in this chapter.

* Perl is the programming language that we will use for the web-server
side code in all of our examples.

* Moose (and its cut-down cousin, Moo) gives a simple and powerful way
to write Object-Oriented code in Perl.

* The Template Toolkit is a great way to separate the parts of our
code that display data to the users from the parts which work out what
we need to show to the users.

* DBIx::Class is used to communicate with a database.

* PSGI is a specification that defines the interaction between a web
server and a web application. It's like a super-charged version of
CGI. Plack is a toolkit for working with that specification.

## Perl

## Moose

When Perl 5 was released in 1994, one of the major new features it
added was the ability to write Object Oriented code. Sometimes, people
complain that Perl's OO functionality feels a bit "bolted-on" to the
existing language. This is a completely fair criticism, as this
feature was bolted on to the existing language.

When the Perl 6 project started, people started to think about how
they really wanted Perl's Object Oriented features to work. Some years
later, when Perl 6 still hadn't appeared, other people started to
wonder whether it was possible to support a Perl 6-style OO system in
Perl 5. The results of these experiments were released to CPAN as
Moose - The Modern Object Oriented System. Since its original release,
Moose has become incredibly popular among Perl programmers and it is
now the de-facto standard approach for OO programming in Perl.

Moose works by adding a number of new keywords to the Perl
language. In fact, these "keywords" are mostly just subroutines, but
they are usually called in a way that disguises that fact. These
keywords allow you to define classes, attributes and methods in a far
more easy way than "classic" Perl 5 OO. Here is a simple example of a
Moose class that models a person.

    package Person;
    use Moose;

    has name => (
        isa      => 'Str',
        is       => 'rw',
        required => 1,
    );

    has dob => (
        isa      => 'DateTime',
        is       => 'ro',
        required => 1,
    );

    has gender => (
        isa      => 'Str',
        is       => 'rw',
        required => 1,
    );

This defines a class called "Person" which has three attributes - a
name, a date of birth and a gender. Classes are defined with the
`package` keyword (because classes are just like any other Perl
package) and attributes are defined with the `has` keyword. Attributes
have a number of properties which are used to define the attribute. In
this example I have used `isa` (to define the type of the attribute),
`is` (to say whether the attribute is read-only or read-write) and
`required` (to say whether the attribute is mandatory or optional) but
there are a number of other options available.

Even with this simple class we can start to write programs. We can
create objects of our class and access their attributes. We can also
change any attributes that are marked as read-write.

    #!/usr/bin/perl
    use strict;
    use warnings;
    use 5.010;
    use DateTime;
    use Person;

    my $newborn = Person->new(
        name   => 'Miles',
        dob    => DateTime->now,
        gender => 'M'
    );

    say $newborn->name; # displays 'Miles'
    say $newborn->dob;  # displays current date
    $newborn->name('Max'); # Parents change their minds
    say $newborn->name; # displays 'Max'

### Generated methods

You'll see from the previous example that Moose has generated some
methods for use. Firstly we get a `new()` method that constructs a new
instance of the class (an object). Moose's `new()` method checks that
all mandatory attributes have been given (using the `required`
property) and also checks that the attributes are all of the correct
types (using the `isa` property). If any of these checks fail then
your program will die with an error message. But if the checks all
pass then you will get back an object that contains all of the data
that you passed to `new()`.

Moose will also give you methods for each of the attributes that you
have defined. By default, these methods have the same name as the
attributes. If you define an attribute as read-only then you can call
an attribute method to get the value of the attribute. If an attribute
is defined as read-write then you can also use the method to change
the value of the attribute by passing a new attribute to the method.

A common name for these methods is "getters and setters" as they allow
you to get and set the values of attributes. You will also see them
called "accessors and mutators" as you use them to access or mutate
(change) attribute values.

### Types

One very useful property is `isa`. This defines the type of the
attribute. We can draw from Moose's set of built-in types (like the
'Str' type that we have used for `name` and `gender`) or we can declare
that the attribute is an object of a particular class (as I have done
for the `dob` attribute). Defining the `dob` attribute as a DateTime
object is very powerful as we can easily get access to extra
information about the date. For example, we can add something like
this to our previous program

    say $newborn->dob->day_name;

There are, however downsides to this. In my current sample code I have
avoided the issue by setting the date of birth to `DateTime->now`
which gives the current date (and time), but often we will need to
create objects containing details of people who aren't being born
right now. Currently, we would need to create a DateTime object for
the correct date.

    use DateTime;
    use Person;

    my $dob = DateTime->new(year => 1962, month => 9, day => 7);
    my $dave = Person->new(
        name   => 'Dave',
        dob    => $dob,
        gender => 'M'm
    );

    say $dave->dob->day_name; # Friday

Another approach might be to construct a DateTime object from a string
using DateTime::Format::Strptime.

    use DateTime::Format::Strptime;
    use Person;

    my $date_parser = DateTime::Format::Strptime->new(
        pattern => '%Y-%m-%d',
    );

    my $dob = $date_parser->parse_datetime('1962-09-07');

    my $dave = Person->new(
        name   => 'Dave',
        dob    => $dob,
       gender => 'M'
    );

    say $dave->dob->day_name;

We can build on this approach to automate this conversion. Moose types
support a feature called _coercion_, where values of one type can be
automatically converted to values of another type. And all of the
complexity can be hidden away in the Person class. We need to add the
following code to Person.pm.

    use Moose::Util::TypeConstraints;
    use DateTime::Format::Strptime;

    subtype 'BirthDate',
        as 'DateTime';

    coerce 'BirthDate',
        from 'Str',
        via {
            return DateTime::Format::Strptime->new(
                pattern => '%Y-%m-%d',
            )->parse_datetime($_);
        };

We start by loading a Moose utility class that we need along with the
DateTime parsing class. We then define a subtype of the DateTime type
(because it's a really bad idea to start messing aroung with base
types). Next we set up the coercion, saying that you can convert a Str
value to a BirthDate value using DateTime::Format::Strptime in the
same way as we used it before. The `via` clause in the `coerce`
definition requires a block of code which takes the input value (which
is stored in `$_` and returns the coerced value.

We also need to make some changes to the definition of the `dob`
attribute - changing the type to our new subtype and setting a flag
which tells Moose that this attribute can be coerced.

    has dob => (
        isa      => 'BirthDate',
        is       => 'ro',
        required => 1,
        coerce   => 1,
    );

Once we have done all of this, we can write some much simpler code to
create our object.

    use Person;

    my $dave = Person->new(
        name   => 'Dave',
        dob    => '1962-09-07',
        gender => 'M'
    );

    say $dave->dob->day_name;

The conversion from a string to a DateTime object happens
automatically and we no longer need to care about it.

Our new BirthDate type is a subtype of DateTime, but any DateTime
object is also a valid DateTime. But we can also define subtypes that
are specialisations of their base type. Take, for example, our
`gender` attribute. We have defined that as a string, and we expect it
to take a value of either 'F' or 'M'. But currently we have nothing in
place to enforce that restriction. Let's fix that.

Again, we'll define a subtype of an existing type. This time we'll
create Gender as a subtype of Str. But this time we will use the
`where` and `message` clauses to define valid values and provide an
error to be displayed when validation fails.

    subtype 'Gender',
        as 'Str',
        where { /^[FM]$/ },
        message { "$_ is not a valid gender. It should be F or M" };

We also need to change the type of the `gender` attribute.

    has gender => (
        isa      => 'Gender',
        is       => 'rw',
        required => 1,
    );

All of our existing code will continue to work, but if we try to
create a new object with an invalid gender we will get an error
message.

    my $dave = Person->new(
        name   => 'Dave',
        dob    => '1962-09-07',
        gender => 'X'
    );

This generates the error "Attribute (gender) does not pass the type
constraint because: X is not a valid gender. It should be F or M".

### Adding Methods

Our current class doesn't do much. It is just a collection of
attributes. Classes become much more useful if you can do other things
with them. For example, our class knows when a person was born, but it
can't tell you how old the person is. To do that we need to add a
method to our class.

    sub age {
        my $self = shift;

        my $duration = DateTime->now - $self->dob;

        return $duration->years;
    }

A method in a Perl class is just a subroutine that is passed one
special parameter - a reference to the object that the method has been
called on. Moose objects are implemented as hash references, but you
generally don't need to care about that as you access the data stored
inside the object using the attribute methods that Moose has given
you.

Inside the method, we copy this special parameter into a variable
called `$self` (that's not a hard and fast rule, but it's a tradition
amongst Perl programmers and you would need a pretty good reason to
give the variable a different name). We then get the date of birth
from the object and subtract that from the current date. This gives us
a `DateTime::Duration` object, and one of the methods on that object
gives us the number of years that the duration covers.

## Template Toolkit

## DBIx::Class

## PSGI/Plack

