-- | Free theorems plugin
-- Andrew Bromage, 2006
module Plugin.Free (theModule) where

import Plugin
import Plugin.Free.FreeTheorem
import Plugin.Type (query_ghci)

theModule = newModule
    { moduleCmds = return
        [ (command "free")
            { help = say "free <ident>. Generate theorems for free"
            , process = \xs -> do
                result <- freeTheoremStr (query_ghci ":t") xs
                say . unwords . lines $ result
            }
        ]
    }
