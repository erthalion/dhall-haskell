{-# LANGUAGE OverloadedStrings #-}

module Dhall.Test.Lint where

import Data.Monoid (mempty, (<>))
import Data.Text (Text)
import Prelude hiding (FilePath)
import Test.Tasty (TestTree)
import Turtle (FilePath)

import qualified Data.Text        as Text
import qualified Data.Text.IO     as Text.IO
import qualified Dhall.Core       as Core
import qualified Dhall.Import     as Import
import qualified Dhall.Lint       as Lint
import qualified Dhall.Parser     as Parser
import qualified Dhall.Test.Util  as Test.Util
import qualified Test.Tasty       as Tasty
import qualified Test.Tasty.HUnit as Tasty.HUnit
import qualified Turtle

lintDirectory :: FilePath
lintDirectory = "./tests/lint"

getTests :: IO TestTree
getTests = do
    formatTests <- Test.Util.discover (Turtle.chars <* "A.dhall") lintTest (Turtle.lstree lintDirectory)

    let testTree = Tasty.testGroup "format tests" [ formatTests ]

    return testTree

lintTest :: Text -> TestTree
lintTest prefix =
    Tasty.HUnit.testCase (Text.unpack prefix) $ do
        let inputFile  = Text.unpack (prefix <> "A.dhall")
        let outputFile = Text.unpack (prefix <> "B.dhall")

        inputText <- Text.IO.readFile inputFile

        parsedInput <- Core.throws (Parser.exprFromText mempty inputText)

        let lintedInput = Lint.lint parsedInput

        actualExpression <- Import.load lintedInput

        outputText <- Text.IO.readFile outputFile

        parsedOutput <- Core.throws (Parser.exprFromText mempty outputText)

        resolvedOutput <- Import.load parsedOutput

        let expectedExpression = Core.denote resolvedOutput

        let message = "The linted expression did not match the expected output"

        Tasty.HUnit.assertEqual message expectedExpression actualExpression
