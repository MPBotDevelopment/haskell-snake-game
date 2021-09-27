module Main where

import SnakeTest
import Testing

-- | A haskell program starts by running the computation defined by
-- 'main'. We run the tests defined in `AutomataTest`.
main :: IO ()
main = runTests tests
