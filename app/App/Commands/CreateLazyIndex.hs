{-# LANGUAGE ScopedTypeVariables #-}

module App.Commands.CreateLazyIndex
  ( cmdCreateLazyIndex
  ) where

import App.Commands.Options.Type
import Control.Lens
import Control.Monad
import Data.Semigroup                     ((<>))
import HaskellWorks.Data.Sv.Internal.Bits
import HaskellWorks.Data.Sv.Internal.Char
import Options.Applicative                hiding (columns)

import qualified App.Commands.Options.Lens                     as L
import qualified App.IO                                        as IO
import qualified Data.ByteString.Builder                       as B
import qualified Data.Vector.Storable                          as DVS
import qualified HaskellWorks.Data.Sv.Internal.ByteString.Lazy as LBS
import qualified HaskellWorks.Data.Sv.Internal.Char.Word64     as CW
import qualified HaskellWorks.Data.Sv.Lazy.Cursor.Internal     as SVL
import qualified System.IO                                     as IO

writeBuilder :: FilePath -> B.Builder -> IO ()
writeBuilder fp b = do
  h <- IO.openFile fp IO.WriteMode
  B.hPutBuilder h b
  IO.hClose h

runCreateLazyIndex :: CreateLazyIndexOptions -> IO ()
runCreateLazyIndex opts = do
  let filePath  = opts ^. L.filePath
  let delimiter = opts ^. L.delimiter

  lbs <- IO.readInputFile filePath

  let ws  = LBS.toVector64Chunks 512 lbs
  let ibq = SVL.makeIbs CW.doubleQuote                      <$> ws
  let ibn = SVL.makeIbs CW.newline                          <$> ws
  let ibd = SVL.makeIbs (CW.fillWord64WithChar8 delimiter)  <$> ws
  let pcq = SVL.makeCummulativePopCount ibq
  let ibr = zip2Or ibn ibd
  let qm  = SVL.makeQuoteMask ibq pcq
  let ib  = zip2And ibr qm

  writeBuilder (filePath <> ".ws.idx")    $ foldMap B.word64LE $ join (DVS.toList <$>  ws) -- +
  writeBuilder (filePath <> ".ibq.idx")   $ foldMap B.word64LE $ join (DVS.toList <$> ibq)
  writeBuilder (filePath <> ".ibn.idx")   $ foldMap B.word64LE $ join (DVS.toList <$> ibn)
  writeBuilder (filePath <> ".ibd.idx")   $ foldMap B.word64LE $ join (DVS.toList <$> ibd)
  writeBuilder (filePath <> ".pcq.idx")   $ foldMap B.word64LE $ join (DVS.toList <$> pcq)
  writeBuilder (filePath <> ".ibr.idx")   $ foldMap B.word64LE $ join (DVS.toList <$> ibr)
  writeBuilder (filePath <> ".qm.idx")    $ foldMap B.word64LE $ join (DVS.toList <$>  qm)
  writeBuilder (filePath <> ".ib.idx")    $ foldMap B.word64LE $ join (DVS.toList <$>  ib)

  return ()

optsCreateLazyIndex :: Parser CreateLazyIndexOptions
optsCreateLazyIndex = CreateLazyIndexOptions
  <$> strOption
        (   long "file"
        <>  help "Separated Value file"
        <>  metavar "STRING"
        )
  <*> option readChar
        (   long "delimiter"
        <>  help "DSV delimiter"
        <>  metavar "CHAR"
        )

cmdCreateLazyIndex :: Mod CommandFields (IO ())
cmdCreateLazyIndex = command "create-lazy-index"  $ flip info idm $ runCreateLazyIndex <$> optsCreateLazyIndex

