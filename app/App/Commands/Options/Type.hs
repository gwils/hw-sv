module App.Commands.Options.Type where

import qualified App.Commands.Options.Internal as I

data CreateIndexOptions = CreateIndexOptions
  { _createIndexOptionsFilePath    :: FilePath
  , _createIndexOptionsDelimiter   :: Char
  , _createIndexOptionsIndexMethod :: I.IndexMethod
  } deriving (Eq, Show)

data CreateFastIndexOptions = CreateFastIndexOptions
  { _createFastIndexOptionsFilePath  :: FilePath
  , _createFastIndexOptionsDelimiter :: Char
  } deriving (Eq, Show)

data QueryOptions = QueryOptions
  { _queryOptionsCreateIndex      :: Bool
  , _queryOptionsColumns          :: [Int]
  , _queryOptionsFilePath         :: FilePath
  , _queryOptionsOutputFilePath   :: FilePath
  , _queryOptionsDelimiter        :: Char
  , _queryOptionsOutputBufferSize :: Maybe Int
  , _queryOptionsFast             :: Bool
  } deriving (Eq, Show)

data GenerateOptions = GenerateOptions
  { _generateOptionsFields :: Int
  , _generateOptionsRows   :: Int
  } deriving (Eq, Show)

data CatOptions = CatOptions
  { _catOptionsSource :: FilePath
  , _catOptionsTarget :: FilePath
  } deriving (Eq, Show)

data CreateLazyIndexOptions = CreateLazyIndexOptions
  { _createLazyIndexOptionsFilePath  :: FilePath
  , _createLazyIndexOptionsDelimiter :: Char
  } deriving (Eq, Show)

data LazyCountFieldsOptions = LazyCountFieldsOptions
  { _lazyCountFieldsOptionsFilePath  :: FilePath
  , _lazyCountFieldsOptionsDelimiter :: Char
  } deriving (Eq, Show)

data QueryLazyOptions = QueryLazyOptions
  { _queryLazyOptionsColumns        :: [Int]
  , _queryLazyOptionsFilePath       :: FilePath
  , _queryLazyOptionsOutputFilePath :: FilePath
  , _queryLazyOptionsDelimiter      :: Char
  , _queryLazyOptionsOutDelimiter   :: Char
  } deriving (Eq, Show)
