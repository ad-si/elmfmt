module Main exposing (RepoChart, Person, EmptyRecord)

type alias RepoChart =
  { numberOfDays : NumberOfDays
  , numberOfRepos : NumberOfRepos
  }


type alias Person = { name : String, age : Int, city : String, country : String }


type alias EmptyRecord = {}
