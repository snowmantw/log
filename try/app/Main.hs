module Main where

import Lib
import Control.Monad.State
import Data.Functor.Identity

type Stack = [] String
pop :: State Stack String
pop = state (\(top:xs) -> (top, xs))

push :: String -> State Stack ()
push str = state (\xs -> ((), str:xs))

initStack :: State Stack ()
initStack = state (\init -> ((), init))

barToApple = \bar -> "apple"

-- We unfortunately StateT is not the same as State, so:
-- "For example, State s is an abbreviation for StateT s Identity"
-- https://hackage.haskell.org/package/base-4.10.0.0/docs/Data-Functor-Identity.html
--
-- And the change in MTL:
--
-- type State s = StateT s Identity
--
-- https://stackoverflow.com/questions/24103108/where-is-the-data-constructor-for-state

initialised :: Stack
initialised =
  case initStack of
    StateT initF -> case initF [] of    -- ((), Stack)
      Identity (_, stack) -> stack 
      

fooPushed :: Stack
fooPushed =
  case push "foo" of
    StateT pushFooF -> case pushFooF initialised of
      Identity (_, stack) -> stack

barPushed :: Stack
barPushed =
  case push "bar" of
    StateT pushBarF -> case pushBarF fooPushed of
      Identity (_, stack) -> stack

barPoped :: (String, Stack)
barPoped =
  case pop of
    StateT popBarF -> case popBarF barPushed of
      Identity (bar, Stack)


-- Not necesary to use fmap... since we can and need to unwrap those functors
-- final = fmap barToApple barPoped


main :: IO ()
main = someFunc
