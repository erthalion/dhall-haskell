-- Using this file:
-- json-to-dhall ./bower.dhall < ./bower.json | dhall
-- Round-trip test:
-- json-to-dhall ./bower.dhall < ./bower.json | dhall | dhall-to-json

{ name            : Text
, description     : Text
, license         : Text
, keywords        : List Text
, repository      : { type : Text, url : Text}
, dependencies    : List { mapKey: Text, mapValue: Text }
, devDependencies : List { mapKey: Text, mapValue: Text }
}
