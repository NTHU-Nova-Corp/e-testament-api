# e-testament-api

API to store and retrieve properties files (documents, electronic accounts)

## Routes

All routes return Json

- GET `/`: Root route shows if Web API is running
- GET `api/v1/properties/`: returns all properties IDs
- GET `api/v1/properties/[ID]`: returns details about a single property with given ID
- POST `api/v1/properties/`: creates a new property

## Install

Install this API by cloning the *relevant branch* and installing required gems from `Gemfile.lock`:

```shell
bundle install
```

## Test

Run the test script:

```shell
ruby spec/api_spec.rb
```

## Execute

Run this API using:

```shell
rackup
```
