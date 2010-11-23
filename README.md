About
-----

Hamster-Basecamp is a web based application that allows you to import
your Hamster time entries into a Basecamp Account.

This project arose out of purse laziness as a quick solution to automate
a menial task. The application assumes a very specific workflow with 
Hamster. Read on for details.

A Bit about Terminology and Workflow
------------------------------------

In order to understand how this application matches up your Hamster time
entries (facts) with Basecamp, a bit of knowledge is required about how
both applications structure their data.

Hamster refers to time entries as "facts".  At the highest level Hamster 
catalogs your facts into "categories". Within these categories, facts are
further sub categoriezed into activities.

This application matches up Hamster categories to Basecamp accounts and
Hamster activities into projects within that account.

HAMSTER  => BASECAMP
Category => Account/Company
Activity => Project
Fact     => Time Entry

Within this application you can configure multiple Basecamp accounts and 
associate those accounts to Hamster "Categories".  Each of the Hamster
"Activities" within the specified Category can be mapped to Basecamp 
projects.

Hamster entries without imported Basecamp time entries will be shown on
the front page.  These entries can be associated with a Basecamp todo
item and imported directly to basecamp.

You can ignore a fact by clicking on the checkbox next to the item or items
you want to ignore and clicking on the "Ignore" button from the front page.

Install
-------

Copy config/database.yml.example to config/database.yml and update production
database location to point to your Hamster database. This can be a copy of
the database, or the same database that Hamster uses which should be in:
~/.local/share/hamster-applet/hamster.db. 

Run RAILS_ENV=production rake db:migrate

Run the application using your desired Rails deployment method.  Apache/
Passenger works great, but unicorn, thin, mongrel, webrick etc. will
work as well.

Development Instructions
------------------------

To get started in development mode, you will want to copy your current
hamster database into the db directory.  rake db:copy_hamster will do
this for you.

Disclaimer
----------
This is pre-alpha, highly untested softwrae.  It is highly recommended that you
back up your Hamster database before using this.  No gaurantees are made as to
the correctness and accuracy of this application.  Use at your own risk.

Privacy Warning
---------------
In order to authenticate to Basecamp, your Basecamp username
and password are stored in plain text in the database.  Be sure no one
is able to see this database that you also don't want peaking into your
configure Basecamp accounts. Again, use at your own risk.
