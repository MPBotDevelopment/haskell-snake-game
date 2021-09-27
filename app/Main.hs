{-# LANGUAGE OverloadedStrings #-}

module Main where

import           Model
import           View
import           Controller
import           CodeWorld
import           Data.Text    (pack, unpack) 
import           System.Random (randomR, mkStdGen, StdGen)

main :: IO ()
main = activityOf initial handleEvent render

-- | The first 'Int' is the number of generations evolved. The second
-- is how far to jump when pressing space.
data Model = Model StdGen Time Mode Habitat

type Time = Int -- each unit of time is approximatley 1/20 of a second.

data Mode = Start | Play | Debug 
  deriving Show

switch :: Mode -> Mode 
switch Debug = Play
switch _ = Debug

start :: Mode -> Mode 
start Start = Play
start m = m

changeMode :: (Mode -> Mode) -> Model -> Model
changeMode change (Model s n m h) = Model s n (change m) h 

-- | The model at the start of a simulation.
initial :: Model
initial = Model (mkStdGen 42) 0 Start initialHabitat


data AppEvent =
  Restart
    -- ^ Return to starting position.
  | ToggleMode
    -- ^ Switch to Debug and back.
  | Turn Direction
    -- ^ The way a player inyteracts with the game by turning the snake.
  | Slither
    -- ^ Step the snake forward one ~step~ slither.
  | Tick
    -- ^ A single unit of time passes. You don't need to worry about this.

handleEvent :: Event -> Model -> Model
handleEvent ev m = case parseEvent m ev of
  Nothing    -> m
  Just appEv -> applyEvent appEv m

-- | CodeWorld has many events and we are not interested in most of
-- them. Parse them to an app-specific event type.
--
-- Further reading, if interested: "Parse, don't validate"
-- https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/
parseEvent :: Model -> Event -> Maybe AppEvent
parseEvent (Model _ steps mode _) ev = case ev of

    KeyPress k -> case parseDirection (unpack k) of
      Just d -> Just (Turn d)
      Nothing 
        | k == " " -> case mode of 
          Debug -> Just Slither
          _     -> Nothing
        | k == "Esc" -> Just Restart
        | k == "D" -> Just ToggleMode
        | otherwise -> Nothing
  
    TimePassing _ -> case mode of
      Play
          | (steps `mod` 4 == 0) -> Just Slither  
          | otherwise -> Just Tick
      _ -> Nothing
  
    _ -> Nothing

applyEvent :: AppEvent -> Model -> Model
applyEvent ev (Model g steps mode h@(Habitat dim rand f snake)) 
 = foodSeed (case ev of
  Restart -> initial
  Turn dir -> Model g steps (start mode) turned
    where turned = Habitat dim rand f (turn dir snake)
  ToggleMode -> Model g steps (switch mode) h
  Tick -> Model g (steps + 1) mode h
  Slither -> Model g (steps + 1) mode (stepHabitat h))
applyEvent ev m = case ev of
  Restart -> initial
  _ -> m

-- | Updates the psuedorandom Int and StdGen generator using randomR
foodSeed :: Model -> Model
foodSeed m@(Model gen steps mode h) = case h of
  Habitat (x,y) _ f s -> Model gen' steps mode (Habitat (x,y) rand f s)
    where (rand, gen') = randomR (1, x * y - 1 - score h) gen
  _ -> m

score :: Habitat -> Int 
score (Habitat _ _ _ (Snake _ _ xs)) = 1 + length xs 
score (GameOver _ r) = case r of
  Full _ -> maxBound
  Dead (Snake _ _ xs) -> 1 + length xs  

render :: Model -> Picture
render (Model _ _ mode h)
  = habitatToPicture h
    & translated (-5) 8 (stringToText scoreText)
    & translated 5 8 (stringToText modeText)
    where 
    scoreText = "Current Score: " ++ (show $ score h)
    modeText = "Mode: " ++ show mode
    stringToText = lettering . pack
