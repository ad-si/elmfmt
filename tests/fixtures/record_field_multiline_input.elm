module Main exposing (request)


request =
    { url = url
    , expect = expectJsonWith202Check
      (LoadedDays fullRepoName)
      decodeGithubWeeks
    }
