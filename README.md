# vagrant-redmine

tag r3.2.1:
-----------

Installed software:
  
  Redmine 3.2.1
  Ruby 2.2 (Rails 4.2)
  PostgreSQL 9.5

In this release postgresql has open port for the host machine.
You can access to the postgresql with the command:

$ psql -h 127.0.0.1 -p 5432 -U postgres

PostgreSQL password is: changeme

If you can't wish access to the postgresql instance in the vagrant
host you can disable port forwarding in the Vagrant file.

tag r3.0.0:
-----------

Redmine 3.0.0 + Ruby 2.2 (Rails 4.2) + PostgreSQL 9.4


tag r2.6.1:
-----------

Redmine 2.6.1 + Ruby 2.1 (Rails 3.2) + PostgreSQL 9.4

