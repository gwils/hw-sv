{-# LANGUAGE ScopedTypeVariables #-}

module HaskellWorks.Data.Sv.Cursor
  ( SvCursor(..)
  , SvMode(..)
  , next
  , snippet
  , nextField
  , nextInterestingBit
  , wordAt
  , nextPosition
  , nextRow
  ) where

import Control.Lens
import Data.Word
import HaskellWorks.Data.RankSelect.Base.Rank1
import HaskellWorks.Data.RankSelect.Base.Select1
import HaskellWorks.Data.RankSelect.CsPoppy
import HaskellWorks.Data.Sv.Char
import HaskellWorks.Data.Sv.Cursor.Type

import qualified Data.ByteString                  as BS
import qualified HaskellWorks.Data.AtIndex        as VL
import qualified HaskellWorks.Data.Sv.Cursor.Lens as L

next :: (Rank1 s, Select1 s) => SvCursor t s -> SvCursor t s
next cursor = cursor
  { svCursorPosition = newPos
  }
  where currentRank = rank1   (svCursorInterestBits cursor) (svCursorPosition cursor)
        newPos      = select1 (svCursorInterestBits cursor) (currentRank + 1)

nextInterestingBit :: (Rank1 s, Select1 s) => SvCursor t s -> Maybe (SvCursor t s)
nextInterestingBit cursor = Just cursor
  { svCursorPosition = newPos
  }
  where currentRank = rank1   (svCursorInterestBits cursor) (svCursorPosition cursor)
        newPos      = select1 (svCursorInterestBits cursor) (currentRank + 1) - 1

nextPosition :: SvCursor BS.ByteString s -> Maybe (SvCursor BS.ByteString s)
nextPosition cursor = if newPos < fromIntegral (VL.length (svCursorText cursor))
  then Just cursor
    { svCursorPosition = newPos
    }
  else Nothing
  where newPos = (svCursorPosition cursor + 1) `min` fromIntegral (cursor ^. L.text & BS.length)

nextField :: (Rank1 s, Select1 s) => SvCursor BS.ByteString s -> Maybe (SvCursor BS.ByteString s)
nextField c = do
  ibCursor <- nextInterestingBit c
  ibWord <- wordAt ibCursor
  if ibWord == pipe
    then nextPosition ibCursor
    else Nothing

nextRow :: (Rank1 s, Select1 s) => SvCursor BS.ByteString s -> Maybe (SvCursor BS.ByteString s)
nextRow c = do
  ibCursor <- nextInterestingBit c
  ibWord <- wordAt ibCursor
  newCursor <- nextPosition ibCursor
  if ibWord == newline
    then Just newCursor
    else if atEnd newCursor
      then Nothing
      else nextRow newCursor

atEnd :: SvCursor BS.ByteString s -> Bool
atEnd c = c ^. L.position >= fromIntegral (BS.length (c ^. L.text))

wordAt :: SvCursor BS.ByteString s -> Maybe Word8
wordAt c = if pos < fromIntegral (BS.length txt)
  then Just (txt VL.!!! fromIntegral pos)
  else Nothing
  where pos = c ^. L.position
        txt = c ^. L.text

snippet :: SvCursor BS.ByteString CsPoppy -> BS.ByteString
snippet c = BS.take (len `max` 0) $ BS.drop posC $ svCursorText c
  where d = next c
        posC = fromIntegral $ svCursorPosition c
        posD = fromIntegral $ svCursorPosition d
        len  = posD - posC - 1