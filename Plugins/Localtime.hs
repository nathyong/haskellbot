--
-- | Simple wrapper over privmsg to get time information via the CTCP
--
module Plugins.Localtime (theModule) where

import Lambdabot
import LBState
import qualified Map as M

newtype LocaltimeModule = LocaltimeModule ()

theModule :: MODULE
theModule = MODULE $ LocaltimeModule ()

type TimeMap = M.Map String  -- the person who's time we requested
                    [String] -- a list of targets waiting on this time

instance Module LocaltimeModule TimeMap where

  moduleHelp _ _      = return "print a user's local time"
  moduleCmds   _      = return ["localtime", "localtime-reply"]
  moduleDefState _    = return M.empty

  -- record this person as a callback, for when we (asynchronously) get a result
  process _ _ whoAsked "localtime" rawWho = do
        let (whoToPing,_) = break (== ' ') rawWho
        modifyMS $ \st -> M.insertWith (++) whoToPing [whoAsked] st
        -- this is a CTCP time call, which returns a NOTICE
        ircPrivmsg' whoToPing "\^ATIME\^A" 

  -- the Base module caught the NOTICE TIME, mapped it to a PRIVMGS, and here it is :)
  process _ _ _ "localtime-reply" text = do
    let (whoGotPinged, time') = break (== ':') text
        time = drop 1 time'

    targets <- withMS $ \st set -> do
        case M.lookup whoGotPinged st of
            Nothing -> return []
            Just xs -> do set (M.insert whoGotPinged [] st) -- clear the callback state
                          return xs
    let msg = "Local time for " ++ whoGotPinged ++ " is " ++ time
    flip mapM_ targets $ flip ircPrivmsg' msg

  process _ _ _ _ _ = error "unknown function"