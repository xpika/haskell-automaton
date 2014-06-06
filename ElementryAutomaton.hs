module ElementryAutomaton where

import System.Cmd
import Data.List
import Control.Monad
import System.IO
import System.Environment

hanging_list' total_size list = hanging_list ((total_size - length list) `div` 2) list

hanging_list hang_size list = end ++ map Just list ++ end
  where end = replicate hang_size Nothing

windowify window_size list | length list < window_size = []
                           | otherwise = take window_size list : windowify window_size (tail list)


rotateList _ [] = []
rotateList 0 xs = xs
rotateList n (x:xs) = rotateList (n-1) (xs++[x])

windowify' window_size list = map (take window_size) $ (\x -> last x : init x) $ take (length list) $ iterate (rotateList 1) list 

windowMap window_size f list  = map f $ windowify window_size list

windowMap' window_size f list  = map f $ windowify' window_size list

initState = [True]

initState' = stateHelper'''' rule30 initState 

initState'' = stateHelper $ hanging_list 32 [True]

iterateRule rule state = iterate (stateHelper'''' rule) state

stateHelper'''' f state = windowMap 3 f $ stateHelper''' state
stateHelper''' state = stateHelper $ stateHelper' state
stateHelper'' state =  state
stateHelper' state = hanging_list (3 - 1) state
stateHelper state = map helper state
 where helper Nothing = False
       helper (Just x) = x

rule30 [True ,True ,True ] = False
rule30 [True ,True ,False] = False
rule30 [True ,False,True ] = False
rule30 [True ,False,False] = True
rule30 [False,True ,True ] = True
rule30 [False,True ,False] = True
rule30 [False,False,True ] = True
rule30 [False,False,False] = False

rule90 [True ,True ,True ] = False
rule90 [True ,True ,False] = True
rule90 [True ,False,True ] = False
rule90 [True ,False,False] = True
rule90 [False,True ,True ] = True
rule90 [False,True ,False] = False
rule90 [False,False,True ] = True
rule90 [False,False,False] = False

rule110 [True ,True ,True ] = False
rule110 [True ,True ,False] = True
rule110 [True ,False,True ] = True
rule110 [True ,False,False] = False
rule110 [False,True ,True ] = True
rule110 [False,True ,False] = True
rule110 [False,False,True ] = True
rule110 [False,False,False] = False

renderIterations iterations = renderIterations' $ map (\x -> hanging_list' lastIterationLength x) iterations 
 where lastIterationLength = length $ last iterations

renderIterations' = renderIterations'' . map stateHelper

renderIterations'' list = map renderIterations''' list

renderIterations''' list = (map convertChar) list
  where convertChar True = '#'
        convertChar False = '.'


eg rule = mapM_  (\x -> do { putStrLn (renderIterations''' x)} ) (iterate (windowMap' 3 rule) (stateHelper $ hanging_list 64 [True]))
eg' rule = iterate (windowMap' 3 rule) (stateHelper $ hanging_list 300 [True])
main = do 
       renderRule 10 rule30
       putStrLn ""
       renderRule 10 rule90
       putStrLn ""
       renderRule 150 rule110

renderRule iterations rule = do 
       mapM_ putStrLn (renderIterations $ take iterations $ iterateRule rule initState)


-- use rule30 as encrytion
encrypt :: [Bool] -> [Bool]
encrypt y = iterate (\x -> stateHelper'''' rule30 x) y !! 3

decrypt :: [Bool] -> [Bool]
decrypt y = (\(Just x)->x) $ find (\x -> encrypt x == y) $ concatMap (\x -> replicateM x [True,False]) [1..]

