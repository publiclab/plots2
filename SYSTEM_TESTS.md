 

# Guide on System Tests in Ruby

System tests in Ruby are special types of tests.

They allow us to interact with our web app, test the UX and JavaScript of our application.

This repository uses [Capybara](https://github.com/teamcapybara/capybara) library to perform system tests. It simulates user's interaction with our web app (visiting pages, clicking buttons, filling forms...)

System tests are the slowest type of tests and we need to be careful when writing them.



Visit the official [Capybara Docs](https://www.rubydoc.info/github/jnicklas/capybara/Capybara) to learn more.



## Test's file structure

The example code below shows how the normal test file looks like and introduces you to the basics of system tests.

```ruby
# Import system test configuration (driver, options...)
require "application_system_test_case"

# Class name should be descriptive and align with the filename
class EditorTest < ApplicationSystemTestCase
    # The time Capybara should wait for a function to complete (visit, find, all...)
    Capybara.default_max_wait_time = 60
    # Other includes and settings
    
    def setup
       # This function doesn't exist in every test file, it's optional.
       # If we define it, it'll run before each test.
       # For example, we want to login the user before each test.
    end
    
    # The standard test structure
    test 'creating 3x3 table in Markdown' do
       # Code ...
    end
    
    # Other tests
end
```



## Basic functions

#### **visit '/path'**

`visit` navigate  to the specific URL. If the page doesn't load in certain period of time(timeout) the test fails.



#### assert_equal 'expected_value', 'actual_value'

`assert_equal` does the assertion. If it evaluates to false, the test fails.



#### click_on 'text'

`click_on` - click on an element that has an ID, NAME or TEXT of 'text'.

The usage of this function is **highly discouraged**, we already had problems with it.

If you were to write `click_on 'Submit'` and there are more than 1 element matching the ID, NAME or TEXT of 'Submit' the test fails.

As you can see it's not specific. We can have elements matching an ID, NAME or TEXT of 'Submit' anywhere on the web page. In fact, it's pretty common. Using this doesn't make our tests future proof. Instead `find` function should be used for selecting and clicking on the specific element.



## Actions

Actions are functions that allow us to perform a certain operation on the element. Logic, right? :smile:



**The ones that you should now:**

- `attach_file` - attach a file to an element
- `fill_in` - fill in the input/textarea elements

```ruby
test 'example test' do
    # Uploads an image
    attach_file("input#profile-image", '/path/to/image')
    
    # Fill in input/textarea element that has an ID, NAME or LABEL TEXT of 'username'
    # It doesn't accept a css selector like #username, the biggest caveat of using this.
    # An alternative is find("#username").set("Vlado") -> check out the section below
    fill_in("username", "Vlado")
end
```



Learn more about [Actions](https://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Actions)



## Finders

Finders are used to select elements from a web page. In this section, you'll learn how to use them.



### find 'selector'

The `find` function is one of the most powerful system tests function. It allows us to select a **single element** on the page just like we would do it in CSS/JavaScript. Any valid CSS/JavaScript selector is a valid `find` selector.

Isn't that cool?

```ruby
test 'example test' do
   # Let's select some elements
   title = find("#heading-primary")
   refresh_btn = find("#btn-refresh")
   message_input = find("#form-input-message")
    
   # The title variable holds Capybara::Node::Element object
   # We can do various things with it :)
    
   title.text # Get the title's text
   refresh_btn.click() # Click on the button
   message_input.set("Great post!") # Fill the input element
    
   # Simulate CTRL + Enter key combination
   message_input.native.send_keys([:control, :return])
    
   # Simulate a single keypress (Enter in our case)
   message_input.native.send_keys(:return)
    
   # More advanced element selection
    
   # Select the first element with a class of 'comment'
   find(".comment", match: :first)
    
   # OR you can do this:
   first(".comment")
   
   # Select the element that **contains** certain text
   find("#btn-refresh", text: "Refresh")
    
   # Select the element that has the **exact same** text
   find("#btn-submit", exact_text: "Submit")
end
```

> IMPORTANT NOTE: If `find` selects multiple elements, the test fails. If you are expecting multiple elements you should either use `all` or provide 'match' argument to select a specific element.



`find` is a very powerful function for selecting elements. Its possibilities are endless. If this doesn't cover your case, you can always check out the [official docs](https://rubydoc.info/github/jnicklas/capybara/master/Capybara%2FNode%2FFinders:find).



### all 'selector'

The purpose of `all` function is to select **multiple elements**. That's the difference between `find` and `all`.

`all` returns an **array of elements** matching 'selector', while `find` returns a **single element**.

```ruby
test 'example test' do
    # Imagine this returns an array of 2 Capybara::Node::Element objects
    buttons = all(".btn")
    
    first_button = buttons[0]
    second_button = buttons[1]
    
    # All methods used on an element we select with 'find' can also be used with elements     # selected with 'all' and other 'finders' functions
    first_button.click()
end
```



`find` and `all` are core functions for selecting elements.



**The other ones are:**

- find_button
- find_link
- find_field
- ...



**Which one should I use?**

Everything that you can do with `find` and `all` you can also do with the above functions. The biggest difference is readability. The functions above are more declarative. You don't need to read a selector to know if you are selecting a button, link or something else. We encourage using `find` and `all` to keep consistency across the tests. 



Learn more about [Finders](https://rubydoc.info/github/jnicklas/capybara/master/Capybara/Node/Finders).



## Matchers

Matchers are used to assert elements on a web page.



### Checking for elements existence

`assert_selector 'selector'` asserts an element matching 'selector' exists on a web page.

`assert_no_selector 'selector'` asserts an element matching 'selector' is not present on a web page.

```ruby
test 'example test' do
   # Check if element exists
   assert_selector('#heading-primary')
    
   # Assert that an element with an ID of heading-secondary and text 'Subheading' exists
   assert_selector('#heading-secondary', text: 'Subheading')
    
   # Assert that an element with an ID of doesnt-exist is not on the page
   assert_no_selector('#doesnt-exist')
end
```



**Similarly to finders, we have other matchers like:**

- has_button
- has_link
- has_field
- ...



Learn more about [Matchers](https://www.rubydoc.info/github/jnicklas/capybara/Capybara/Node/Matchers).



## Run JavaScript in Ruby!

Sometimes you need to write a piece of JavaScript to simulate certain a interaction that is not possible otherwise. For example, faking an image upload event.



Capybara provides us with 2 useful functions that allow us to do this:

- `evaluate_script` - evaluate the script and return the result.
- `evaluate_async_script` - evaluate script that uses event loop (Ajax requests, Promises...)
- `execute_script` - execute the script without returning the result

```ruby
test 'example test' do
    # product is 4
    product = evaluate_script("2 + 2")
    
    # Waits until request completes and assigns 'data' variable's value to user_info
    user_info = evaluate_async_script <<-JS
		const data = fetch("/user-info").then(res=>res.json());
		return data;
	JS
    
    execute_script <<-JS
		document.querySelector(".spinner").remove()
		console.log("The spinner has been removed!")
	JS
end
```

In the first example I use `evaluate_script` with parentheses and the script is wrapped inside of double quotes. In the second example I use `execute_script` with the weird looking `<<-JS JSCode JS` syntax.

It's just a general practise to use `<<-JS JSCode JS` when you have a longer script.



## Appendix

### Double quotes VS single quotes in tests?

We mostly use single quotes in tests **except** for assertions that contain escape characters like `\n` or string interpolation `#{expression}`. This concept doesn't apply for tests only, it's the general Ruby feature :)

In single quotes `\n` is not interpreted as a new line, rather as a string \n. The same applies to interpolation.

```ruby
test 'example test' do
    string_single_quotes = '\nAn empty line comes before me.'
    string_double_quotes = "\nAn empty line comes before me."
    
    # This would fail because it compares:
    # `\nAn empty line comes before me.`
    # with
    # `
    # An empty line comes before me.`
    assert_equal(string_single_quotes, string_double_quotes)
    
    name = "Vlado"
    single_quotes_interpolation = 'My name is #{name}.'
    double_quotes_interpolation = "My name is #{name}."
    
    # This would also fail, it compares:
    # `My name is #{name}.`
    # with
    # `My name is Vlado.`
    assert_equal(single_quotes_interpolation, double_quotes_interpolation)
end
```



### Unable to find hidden elements?

Finders functions are not able to find an element that is hidden. For example an element like `<input type="hidden" id="image-input-hidden">` can't be found.



In order make hidden elements visible to Capybara we disable the option:

`Capybara.ignore_hidden_elements = false`

After we find our hidden element, we have to enable the option again. Leaving it disabled is considered a bad practice and can lead to various errors.

```ruby
test 'example test' do
    Capybara.ignore_hidden_elements = false
    hidden_image_input = find('#image-input-hidden')
    Capybara.ignore_hidden_elements = true
    
    # ...
end
```

This is **the correct way** to select and interact with hidden elements.



You might have seen this code being used for the same purpose. This code is prone to failure and **shouldn't be used**.

```ruby
test 'example test' do
   # This only works if element has an opacity of 0, but if it has visibility: hidden rule    # set or type="hidden" attribute, the test FAILS!
   find("#image-input-hidden", visible: false) 
end
```

