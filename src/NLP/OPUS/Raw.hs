module NLP.OPUS.Raw (parseRaw) where

import NLP.OPUS.Util (mkCorpus)
import NLP.OPUS.Types

import Data.Text (Text, pack)
import Data.List (transpose)
import Text.XML.HXT.Expat
import Text.XML.HXT.Core

-- | Raw OPUS format parser
--   Input is a list of pairs: language name - raw file path.
parseRaw :: [(Lang, FilePath)] -> IO Corpus
parseRaw langFiles =
    fmap (mkCorpus . consistentCheck . rawConverter) $
        mapM runParser files
  where
    files = map snd langFiles
    langs = map fst langFiles
    rawConverter = map (zip langs) . transpose
    runParser f  = runX $
        readDocument [ withValidate no
                     , withExpat yes
                     ] f >>> rawParser
    consistentCheck c
        | all ((== length (head c)) . length) c = c
        | otherwise = error "unaligned source"

rawParser :: ArrowXml a => a XmlTree Text
rawParser = getChildren >>>
    hasName "DOC" //> hasName "s" >>> getChildren >>> getText >>^ pack

