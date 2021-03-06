module Main where

import Control.Monad
import Data.ByteString                      (ByteString)
import Data.Vector                          (Vector)
import HaskellWorks.Data.RankSelect.CsPoppy
import Weigh

import qualified Data.ByteString.Lazy               as LBS
import qualified Data.Csv                           as CSV
import qualified Data.Vector                        as DV
import qualified HaskellWorks.Data.Sv.Strict.Cursor as SVS
import qualified HaskellWorks.Data.Sv.Strict.Load   as SVS

repeatedly :: (a -> Maybe a) -> a -> [a]
repeatedly f a = a:case f a of
  Just b  -> repeatedly f b
  Nothing -> []

loadCsv :: FilePath -> IO (DV.Vector (DV.Vector ByteString))
loadCsv filePath = do
  c <- SVS.mmapDataFile2 ',' True filePath

  rows <- forM (repeatedly SVS.nextRow c) $ \row -> do
    let fieldCursors = repeatedly SVS.nextField row :: [SVS.SvCursor ByteString CsPoppy]
    let fields = DV.fromList (SVS.snippet <$> fieldCursors)

    return fields

  return (DV.fromList rows)

main :: IO ()
main = do
  let infp  = "data/bench/data-0001000.csv"
  mainWith $ do
    setColumns [Case, Allocated, Max, Live, GCs]
    sequence_
      [ action "cassava/decode/Vector ByteString" $ do
          r <- fmap (CSV.decode CSV.HasHeader) (LBS.readFile infp) :: IO (Either String (Vector (Vector ByteString)))
          case r of
            Left _  -> error "Unexpected parse error"
            Right v -> pure v
      , action "hw-sv/decode/Vector ByteString" $ do
          v <- loadCsv infp :: IO (Vector (Vector ByteString))
          pure v
      ]
  return ()
