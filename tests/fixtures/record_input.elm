module Main exposing (person, emptyRecord, multilineRecord, recordUpdate)


person = {   name   =   "Alice"   ,   age   =   30   ,   city   =   "Boston"   }


emptyRecord = {}


multilineRecord = { name = "Bob",
    age = 25, city = "New York", country = "USA" }


recordUpdate = { baseConfig
    | privateRepos = True, repoChart = RepoChart 365 100, userChart = UserChart 500 100
    }
