module HaskellWorks.Data.Sv.Internal.Char where

import Data.Char
import Data.Semigroup      ((<>))
import Data.Word
import Options.Applicative (ReadM, eitherReader)

doubleQuote :: Word8
doubleQuote = fromIntegral (ord '"')

comma :: Word8
comma = fromIntegral (ord ',')

pipe :: Word8
pipe = fromIntegral (ord '|')

newline :: Word8
newline = fromIntegral (ord '\n')

readChar :: ReadM Char
readChar = eitherReader $ \xs -> case xs of
  [a] -> return a
  _   -> Left $ "Invalid delimeter " <> show xs
