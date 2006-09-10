--
-- Copyright (c) 2004 Don Stewart - http://www.cse.unsw.edu.au/~dons
-- GPL version 2 or later (see http://www.gnu.org/copyleft/gpl.html)
--

--
-- | QuickCheck. use hs-plugins to run a Haskell expression under
-- controlled conditions.
--
import System.Eval.Haskell      (unsafeEval_)

import Data.Char                (chr)
import Data.Maybe               (isJust, fromJust)
import Control.Monad

import System.Random
import System.Exit              (exitWith, ExitCode(ExitSuccess))
import System.IO                (getContents, putStrLn)
import System.Posix.Resource    (setResourceLimit,
                                 Resource(ResourceCPUTime),
                                 ResourceLimits(ResourceLimits),
                                 ResourceLimit(ResourceLimit))
import Test.QuickCheck

import qualified Control.Exception

rlimit = ResourceLimit 3

context = prelude ++ prehier ++ datas ++ qualifieds ++ controls ++ other ++ template ++ extras

prelude = ["qualified Prelude as P", "Prelude"]

other = ["Text.Printf"]

prehier = ["Char", "List", "Maybe", "Numeric", "Random" ]

qualifieds = ["qualified Data.Map as M"
             ,"qualified Data.Set as S"
             ,"qualified Data.IntSet as I"]

datas   = map ("Data." ++) [
                "Array", "Complex",
                "Bits", "Bool", "Char", "Dynamic", "Either", 
                "Graph", "Int", "Ix", "List",
                "Maybe", "Ratio", "Tree", "Tuple", "Typeable", "Word" 
              ]

controls = map ("Control." ++) ["Monad", "Monad.Cont", "Monad.State", "Monad.ST", "Monad.Writer", "Monad.Reader", "Monad.Fix", "Arrow"]

main = do
    setResourceLimit ResourceCPUTime (ResourceLimits rlimit rlimit)
    s <- getLine
    when (not . null $ s) $ do
        x <- sequence (take 3 (repeat $ getStdRandom (randomR (97,122)) >>= return . chr))
        s <- unsafeEval_ ("let { "++x++
                         " = \n# 1 \"<irc>\"\n"++s++
                         "\n} in (quickCheck "++x++
                         ")") context [] [] []
        case s of
            Left  e -> e
            Right v -> Control.Exception.catch
                (putStrLn v)
                (\e -> Control.Exception.handle (const $ putStrLn "Exception") $ do
                            e' <- Control.Exception.evaluate e
                            putStrLn $ "Exception: " ++ take 1024 (show e'))
    exitWith ExitSuccess
