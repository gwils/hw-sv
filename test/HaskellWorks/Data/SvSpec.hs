{-# LANGUAGE BangPatterns        #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE ScopedTypeVariables #-}

module HaskellWorks.Data.SvSpec (spec) where

import Control.Concurrent
import Control.Monad.IO.Class
import Data.Word
import HaskellWorks.Data.Bits.BitRead
import HaskellWorks.Data.Bits.BitShow
import HaskellWorks.Data.FromByteString
import HaskellWorks.Hspec.Hedgehog
import Hedgehog
import Test.Hspec

import qualified Data.Vector.Storable                        as DVS
import qualified HaskellWorks.Data.Sv.Strict.Cursor.Internal as SVS
import qualified HaskellWorks.Data.Sv.Strict.Load            as SVS

{-# ANN module ("HLint: ignore Redundant do"        :: String) #-}
{-# ANN module ("HLint: ignore Reduce duplication"  :: String) #-}
{-# ANN module ("HLint: redundant bracket"          :: String) #-}

spec :: Spec
spec = describe "HaskellWorks.Data.SvSpec" $ do
  it "Parsing Basic DSV" $ requireTest $ do
    let bs =  "12345678,12345678,123456,abcdefghijklmnopqrstuvwxyz\n\
              \12345678,12345678,123456,abcdefghijklmnopqrstuvwxyz\n\
              \12345678,12345678,123456,abcdefghijklmnopqrstuvwxyz\n\
              \12345678,12345678,123456,abcdefghijklmnopqrstuvwxyz"
    let Just (expected :: [Word64]) = bitRead
          "00000000 10000000 01000000 10000000 00000000 00000000 00010000 00001000 \
          \00000100 00001000 00000000 00000000 00000001 00000000 10000000 01000000 \
          \10000000 00000000 00000000 00010000 00001000 00000100 00001000 00000000 \
          \00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"

    let v = fromByteString bs
    let actual = SVS.mkDsvInterestBits ',' v

    bitShow actual ===  "00000000 10000000 01000000 10000000 00000000 00000000 00010000 00001000 \
                        \00000100 00001000 00000000 00000000 00000001 00000000 10000000 01000000 \
                        \10000000 00000000 00000000 00010000 00001000 00000100 00001000 00000000 \
                        \00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"
  it "Parsing Quoted DSV" $ requireTest $ do
    let bs =  "12345678,12345678,123456,\"bcdefghijklmnopqrstuvwxy\"\n\
              \12345678,12345678,123456,\"bcdefghijklmnopqrstuvwxy\"\n\
              \12345678,12345678,123456,\"bcdefghijklmnopqrstuvwxy\"\n\
              \12345678,12345678,123456,\"bcdefghijklmnopqrstuvwxy\""
    let Just (expected :: [Word64]) = bitRead
          "00000000 10000000 01000000 10000000 00000000 00000000 00010000 00001000 \
          \00000100 00001000 00000000 00000000 00000001 00000000 10000000 01000000 \
          \10000000 00000000 00000000 00010000 00001000 00000100 00001000 00000000 \
          \00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"

    let v = fromByteString bs
    let !actual = SVS.mkDsvInterestBits ',' v

    bitShow actual ===  "00000000 10000000 01000000 10000000 00000000 00000000 00010000 00001000 \
                        \00000100 00001000 00000000 00000000 00000001 00000000 10000000 01000000 \
                        \10000000 00000000 00000000 00010000 00001000 00000100 00001000 00000000 \
                        \00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"
  it "Parsing Quoted DSV" $ requireTest $ do
    let bs =  "12345678,12345678,123456,\"bcdefghijklm,opqrstuvwxy\"\n\
              \12345678,12345678,123456,\"bcdefghijklm,opqrstuvwxy\"\n\
              \12345678,12345678,123456,\"bcdefghijklm,opqrstuvwxy\"\n\
              \12345678,12345678,123456,\"bcdefghijklm,opqrstuvwxy\""
    let Just (expected :: [Word64]) = bitRead
          "00000000 10000000 01000000 10000000 00000000 00000000 00010000 00001000 \
          \00000100 00001000 00000000 00000000 00000001 00000000 10000000 01000000 \
          \10000000 00000000 00000000 00010000 00001000 00000100 00001000 00000000 \
          \00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"

    let v = fromByteString bs
    let !actual = SVS.mkDsvInterestBits ',' v

    bitShow actual ===  "00000000 10000000 01000000 10000000 00000000 00000000 00010000 00001000 \
                        \00000100 00001000 00000000 00000000 00000001 00000000 10000000 01000000 \
                        \10000000 00000000 00000000 00010000 00001000 00000100 00001000 00000000 \
                        \00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000"

