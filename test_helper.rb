ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'factory_girl'


class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...

  #taken from http://www.nullislove.com/2008/01/23/testing-in-rails-part-8-validations/
  def assert_valid(object, msg="Object is invalid when it should be valid")
    assert(object.valid?, msg)
  end

  def assert_not_valid(object, msg="Object is valid when it should be invalid")
    assert(!object.valid?, msg)
  end

  alias :assert_invalid :assert_not_valid

  def assert_presence_required(object, field)
    # Test that the initial object is valid
    assert_valid(object)

    # Test that it becomes invalid by removing the field
    temp = object.send(field)
    object.send("#{field}=", nil)
    assert_invalid(object)
    assert(object.errors.invalid?(field), "Expected an error on validation")

    # Make object valid again
    object.send("#{field}=", temp)
  end

  def assert_belongs_to(child, parent, fieldname)
    parent_obj = child.send(fieldname)
    assert_equal(parent.id, parent_obj.id)
    id_value = child.send("#{fieldname}_id")
    assert_equal(parent.id, id_value)
  end

  def assert_has_many(parent, field, expected=1)
    children = parent.send(field)
    parentid_field = parent.class.to_s.downcase

    assert_equal(expected, children.count)
    assert_equal([parent.id] * expected, children.collect { |c| c.send("#{parentid_field}_id")})
  end

  def assert_sorted(objects, field, min)
    objects.each {  |obj|
      previous_value ||= min
      assert(previous_value <= obj.send(field))
      previous_value = obj.send(field)
    }
  end
end
