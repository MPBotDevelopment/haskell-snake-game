{-|
Module      : Model
Description : Types and starting states for the snake game.
Copyright   : (c) 2021 The Australian National University, Your Name Here
License     : AllRightsReserved
-}
module Model where

-- | Data type for our Snake
data Snake = Snake
             Location
             -- ^ The location (coordinates) of the snake's head.
             Direction
             -- ^ The direction the snake is facing.
             [Direction] 
             -- ^ A list of directions describing the location of each section
             -- of the snake's body relative to the previous section.
   deriving (Show, Eq)

-- | While our game is running, a snake lives in a habitat: 
data Habitat = Habitat 
               -- ^ Constructor for when the Snake is alive and
               -- the game is running.
               Dimensions 
               -- ^ The Habitat has dimensions - (length, height).  
               Int 
               -- ^ The Habitat holds a random number,
               -- which will be used to move the snake's food.
               Food
               -- ^ The Food for the snake will be stored here.
               Snake 
               -- ^ And the snake itself.
               | GameOver Dimensions Result
               -- ^ This constructor is for when the game has ended.
   deriving (Show, Eq)

data Result = Dead Snake | Full Snake
   deriving (Show, Eq)

-- | You can set the starting dimension here. Your code only needs
-- to work when both length and height are greater than 4, but you may allow it
-- to work for smaller habitats for testing purposes.
initialHabitat :: Habitat
initialHabitat = habitat (12,12)

-- | Given dimensions (length, width), return the initial 
-- habitat of those dimensions.
habitat :: Dimensions -> Habitat
habitat dim = Habitat dim 0 initialFood (initialSnake dim)

-- | Type alias for locations. This makes it clear when we are
-- talking about a location specifically, as opposed to another 
-- pair of integers. Consistent with the Dimensions type,
-- the first Int represents horizontal position, and the
-- second represents vertical position.
type Location = (Int, Int)

-- | The other pair of integers we will often use
-- will refer to the dimensions of the habitat the 
-- snake is in. Using these aliases will help avoid confusion
-- between the two.
type Dimensions = (Int, Int)

-- | We need this empty type named Direction for our Habitat type
-- to compile, but this type is not sufficient!
-- Delete this definition, and define the Direction type yourself below.
type Direction = ()

-- | TODO: Direction data type.
-- data Direction = undefined
--     deriving (Show, Eq)

-- | TODO: initialSnake
initialSnake :: Dimensions -> Snake
initialSnake = undefined

-- | We need this empty type named Food for our Habitat type
-- to compile, but this type is not sufficient! 
-- Delete this definition, and define the Food type yourself below. 
type Food = () 

-- | TODO: Food data type.
-- data Food = undefined 
--     deriving (Show, Eq)

-- | TODO: initialFood
initialFood :: Food
initialFood = undefined
