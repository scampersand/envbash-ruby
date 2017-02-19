# Contributing to envbash

You know, so I can remember how to do this stuff.

## Running the tests

First, you probably want to set up [RVM][rvm] or [rbenv][rbenv] to isolate
development, or use [virtualenv][virtualenv] like I do.

Next install the dependencies:

    $ bundle install

Then run the tests:

    $ rake test
    Run options: --seed 54398

    # Running:

    .......okay!
    .......

    Finished in 0.729666s, 19.1869 runs/s, 41.1147 assertions/s.

    14 runs, 30 assertions, 0 failures, 0 errors, 0 skips
    Coverage report generated for Unit Tests to /home/aron/src/ss/envbash-ruby/coverage. 135 / 135 LOC (100.0%) covered.

## Making a release

Bump the version in `envbash.gemspec`, commit it, then:

    $ rake release

## Helpful references

* http://guides.rubygems.org/make-your-own-gem/
* https://www.noppanit.com/create-simple-vagrant-plugin/
* http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/


[rvm]: https://rvm.io/
[rbenv]: https://github.com/rbenv/rbenv
[virtualenv]: http://arongriffis.com/2017/02/18/ruby-virtualenv
